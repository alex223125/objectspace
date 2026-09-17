# frozen_string_literal: true

module Api
  module V1
    module Admin
      module Ecosystems
        module LoadSources
          module EntityTemplates
            module EntityTemplateVersion
              class DefinitionTemplateSerializer
                def initialize(definition)
                  @definition = definition
                end

                def as_json(*)
                  fields = normalized_fields

                  Rails.logger.info(
                    "[DefinitionLibrary API] serialize " \
                    "id=#{definition.id} " \
                    "name=#{value(:name, fallback: "Definition").inspect} " \
                    "fields_count=#{fields.length}"
                  )

                  {
                    id: definition.id.to_s,

                    slug: value(
                      :slug,
                      fallback: definition.id.to_s
                    ),

                    name: value(
                      :name,
                      fallback: value(
                        :title,
                        fallback: "Definition"
                      )
                    ),

                    title: value(
                      :title,
                      fallback: value(
                        :name,
                        fallback: "Definition"
                      )
                    ),

                    category: value(
                      :category,
                      fallback: "General"
                    ),

                    subcategory: value(:subcategory),

                    description: value(
                      :description,
                      fallback: "Production-ready definition template."
                    ),

                    icon: value(
                      :icon,
                      fallback: "✦"
                    ),

                    version: normalized_version,

                    fields: fields,

                    field_count: fields.length,

                    required_count: required_fields_count(fields),

                    active_count: active_fields_count(fields),

                    tags: normalized_tags,

                    popularity: normalized_popularity,

                    featured: boolean_value(
                      :featured
                    ),

                    new: boolean_value(
                      :new,
                      fallback: false
                    ),

                    metadata: normalized_metadata
                  }
                end

                private

                attr_reader :definition

                # ============================================================
                # Generic attribute helpers
                # ============================================================

                def value(attribute, fallback: nil)
                  return fallback unless definition.respond_to?(attribute)

                  result = definition.public_send(attribute)

                  if result.nil? || result.to_s.strip.empty?
                    fallback
                  else
                    result
                  end
                end

                def boolean_value(attribute, fallback: false)
                  return fallback unless definition.respond_to?(attribute)

                  raw_value = definition.public_send(attribute)

                  return fallback if raw_value.nil?

                  ActiveModel::Type::Boolean.new.cast(raw_value)
                end

                # ============================================================
                # Version
                # ============================================================

                def normalized_version
                  raw_version = value(
                    :version,
                    fallback: 1
                  )

                  version = raw_version.to_i

                  version.positive? ? version : 1
                end

                # ============================================================
                # Fields
                # ============================================================

                def normalized_fields
                  raw_fields = fields_from_definition_json

                  if raw_fields.present?
                    Rails.logger.info(
                      "[DefinitionLibrary API] fields_source=definition_json " \
                      "id=#{definition.id} " \
                      "count=#{raw_fields.length}"
                    )

                    return normalize_fields(raw_fields)
                  end

                  raw_fields = fields_from_fields_column

                  if raw_fields.present?
                    Rails.logger.info(
                      "[DefinitionLibrary API] fields_source=fields " \
                      "id=#{definition.id} " \
                      "count=#{raw_fields.length}"
                    )

                    return normalize_fields(raw_fields)
                  end

                  raw_fields = fields_from_field_definitions

                  if raw_fields.present?
                    Rails.logger.info(
                      "[DefinitionLibrary API] fields_source=field_definitions " \
                      "id=#{definition.id} " \
                      "count=#{raw_fields.length}"
                    )

                    return normalize_fields(raw_fields)
                  end

                  raw_fields = fields_from_schema

                  if raw_fields.present?
                    Rails.logger.info(
                      "[DefinitionLibrary API] fields_source=schema " \
                      "id=#{definition.id} " \
                      "count=#{raw_fields.length}"
                    )

                    return normalize_fields(raw_fields)
                  end

                  Rails.logger.warn(
                    "[DefinitionLibrary API] Definition #{definition.id} " \
                    "has no usable fields. " \
                    "columns=#{definition.class.column_names.inspect}"
                  )

                  []
                end

                # ------------------------------------------------------------
                # Primary source:
                # definition_json["fields"]
                # ------------------------------------------------------------

                def fields_from_definition_json
                  return [] unless definition.respond_to?(:definition_json)

                  json = definition.definition_json

                  return [] unless json.is_a?(Hash)

                  fields =
                    json["fields"] ||
                    json[:fields]

                  return [] unless fields.is_a?(Array) || fields.is_a?(Hash)

                  fields
                end

                # ------------------------------------------------------------
                # Secondary source:
                # fields column
                # ------------------------------------------------------------

                def fields_from_fields_column
                  return [] unless definition.respond_to?(:fields)

                  fields = definition.fields

                  return [] if fields.nil?

                  return fields if fields.is_a?(Array) || fields.is_a?(Hash)

                  []
                end

                # ------------------------------------------------------------
                # Optional field_definitions source
                # ------------------------------------------------------------

                def fields_from_field_definitions
                  return [] unless definition.respond_to?(:field_definitions)

                  fields = definition.field_definitions

                  return [] if fields.nil?

                  return fields if fields.is_a?(Array) || fields.is_a?(Hash)

                  []
                end

                # ------------------------------------------------------------
                # Optional schema source
                # ------------------------------------------------------------

                def fields_from_schema
                  return [] unless definition.respond_to?(:schema)

                  extract_fields_from_schema(
                    definition.schema
                  )
                end

                # ============================================================
                # Normalize fields
                # ============================================================

                def normalize_fields(raw_fields)
                  case raw_fields
                  when Array
                    raw_fields.map.with_index do |field, index|
                      normalize_field(field, index)
                    end

                  when Hash
                    raw_fields.map.with_index do |(key, field), index|
                      if field.is_a?(Hash)
                        normalize_field(
                          field.merge(
                            "name" => (
                              field["name"] ||
                              field[:name] ||
                              key
                            )
                          ),
                          index
                        )
                      else
                        normalize_field(
                          {
                            "name" => key,
                            "type" => field
                          },
                          index
                        )
                      end
                    end

                  else
                    []
                  end
                end

                def normalize_field(field, index)
                  field =
                    if field.respond_to?(:to_h)
                      field.to_h
                    else
                      {}
                    end

                  field = stringify_keys(field)

                  {
                    id: field["id"] ||
                      field["key"] ||
                      field["name"] ||
                      "field_#{index + 1}",

                    name: field["name"] ||
                      field["label"] ||
                      field["key"] ||
                      "Field #{index + 1}",

                    key: field["key"] ||
                      field["name"] ||
                      "field_#{index + 1}",

                    label: field["label"] ||
                      field["name"] ||
                      field["key"] ||
                      "Field #{index + 1}",

                    type: field["type"] ||
                      field["field_type"] ||
                      "text",

                    required: boolean_from_hash(
                      field,
                      "required",
                      false
                    ),

                    active: boolean_from_hash(
                      field,
                      "active",
                      true
                    ),

                    description: field["description"],

                    placeholder: field["placeholder"],

                    default: field["default"],

                    options: field["options"] || [],

                    metadata: field["metadata"] || {}
                  }.compact
                end

                # ============================================================
                # Field statistics
                # ============================================================

                def required_fields_count(fields)
                  fields.count do |field|
                    field[:required] == true
                  end
                end

                def active_fields_count(fields)
                  fields.count do |field|
                    field[:active] != false
                  end
                end

                # ============================================================
                # Tags
                # ============================================================

                def normalized_tags
                  raw_tags =
                    if definition.respond_to?(:tags)
                      definition.tags
                    elsif definition.respond_to?(:keywords)
                      definition.keywords
                    else
                      []
                    end

                  case raw_tags
                  when Array
                    raw_tags
                      .map(&:to_s)
                      .map(&:strip)
                      .reject(&:blank?)
                      .uniq

                  when String
                    raw_tags
                      .split(",")
                      .map(&:strip)
                      .reject(&:blank?)
                      .uniq

                  else
                    []
                  end
                end

                # ============================================================
                # Popularity
                # ============================================================

                def normalized_popularity
                  return 0 unless definition.respond_to?(:popularity)

                  raw_value = definition.popularity

                  return 0 if raw_value.nil?

                  raw_value.to_i
                end

                # ============================================================
                # Metadata
                # ============================================================

                def normalized_metadata
                  raw_metadata =
                    if definition.respond_to?(:metadata)
                      definition.metadata
                    elsif definition.respond_to?(:settings)
                      definition.settings
                    else
                      {}
                    end

                  raw_metadata.is_a?(Hash) ? raw_metadata : {}
                end

                # ============================================================
                # Schema extraction
                # ============================================================

                def extract_fields_from_schema(schema)
                  return [] unless schema.is_a?(Hash)

                  schema["fields"] ||
                    schema[:fields] ||
                    []
                end

                # ============================================================
                # Boolean normalization
                # ============================================================

                def boolean_from_hash(hash, key, fallback)
                  value = hash[key]

                  return fallback if value.nil?

                  ActiveModel::Type::Boolean.new.cast(value)
                end

                # ============================================================
                # Hash normalization
                # ============================================================

                def stringify_keys(hash)
                  hash.each_with_object({}) do |(key, value), result|
                    result[key.to_s] = value
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
