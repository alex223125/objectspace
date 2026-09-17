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
                    "name=#{definition_name.inspect} " \
                    "fields_count=#{fields.length}"
                  )

                  {
                    id: definition.id.to_s,

                    slug: value(
                      :slug,
                      fallback: value(:key, fallback: definition.id.to_s)
                    ),

                    name: definition_name,

                    title: value(
                      :title,
                      fallback: definition_name
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
                      :featured,
                      fallback: false
                    ),

                    new: normalized_new,

                    metadata: normalized_metadata
                  }
                end

                private

                attr_reader :definition

                # ---------------------------------------------------------
                # BASIC VALUES
                # ---------------------------------------------------------

                def definition_name
                  value(
                    :name,
                    fallback: value(
                      :title,
                      fallback: "Definition"
                    )
                  )
                end

                def value(attribute, fallback: nil)
                  return fallback unless definition.respond_to?(attribute)

                  result = definition.public_send(attribute)

                  if result.nil?
                    fallback
                  elsif result.respond_to?(:to_s) && result.to_s.strip.empty?
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

                # ---------------------------------------------------------
                # VERSION
                # ---------------------------------------------------------

                def normalized_version
                  raw_version = value(
                    :version,
                    fallback: definition_json_value(
                      "version",
                      fallback: 1
                    )
                  )

                  integer = raw_version.to_i

                  integer.positive? ? integer : 1
                end

                # ---------------------------------------------------------
                # FIELDS
                #
                # IMPORTANT:
                #
                # The database currently contains:
                #
                #   fields: []
                #
                # while the actual fields are stored in:
                #
                #   definition_json:
                #     {
                #       "fields" => [...]
                #     }
                #
                # Therefore we must NOT stop at definition.fields when it
                # is an empty array.
                # ---------------------------------------------------------

                def normalized_fields
                  raw_fields = fields_from_definition

                  Rails.logger.info(
                    "[DefinitionLibrary API] fields_source=#{fields_source} " \
                    "id=#{definition.id} " \
                    "raw_fields_class=#{raw_fields.class} " \
                    "raw_fields_count=#{raw_fields.respond_to?(:length) ? raw_fields.length : 0}"
                  )

                  normalized = normalize_fields(raw_fields)

                  Rails.logger.info(
                    "[DefinitionLibrary API] normalized_fields_count=#{normalized.length} " \
                    "id=#{definition.id}"
                  )

                  normalized
                end

                def fields_from_definition
                  # -------------------------------------------------------
                  # 1. Try the dedicated `fields` column.
                  #
                  # If it contains actual fields, use it.
                  # If it is [] / blank, continue to definition_json.
                  # -------------------------------------------------------
                  if definition.respond_to?(:fields)
                    raw_fields = definition.fields

                    if populated_fields?(raw_fields)
                      return raw_fields
                    end
                  end

                  # -------------------------------------------------------
                  # 2. Try definition_json.
                  #
                  # This is where your Product fields currently live.
                  # -------------------------------------------------------
                  json_fields = fields_from_definition_json

                  if populated_fields?(json_fields)
                    return json_fields
                  end

                  # -------------------------------------------------------
                  # 3. Legacy/fallback accessors.
                  # -------------------------------------------------------
                  if definition.respond_to?(:field_definitions)
                    raw_fields = definition.field_definitions

                    return raw_fields if populated_fields?(raw_fields)
                  end

                  if definition.respond_to?(:schema)
                    raw_fields = extract_fields_from_schema(
                      definition.schema
                    )

                    return raw_fields if populated_fields?(raw_fields)
                  end

                  []
                end

                def fields_source
                  if definition.respond_to?(:fields) &&
                     populated_fields?(definition.fields)
                    "fields"
                  elsif populated_fields?(fields_from_definition_json)
                    "definition_json.fields"
                  elsif definition.respond_to?(:field_definitions) &&
                        populated_fields?(definition.field_definitions)
                    "field_definitions"
                  elsif definition.respond_to?(:schema) &&
                        populated_fields?(
                          extract_fields_from_schema(definition.schema)
                        )
                    "schema.fields"
                  else
                    "none"
                  end
                end

                def populated_fields?(fields)
                  case fields
                  when Array
                    fields.any?
                  when Hash
                    fields.any?
                  else
                    false
                  end
                end

                def fields_from_definition_json
                  return nil unless definition.respond_to?(:definition_json)

                  json = definition.definition_json

                  return nil unless json.is_a?(Hash)

                  json["fields"] || json[:fields]
                end

                def normalize_fields(raw_fields)
                  case raw_fields
                  when Array
                    raw_fields.map.with_index do |field, index|
                      normalize_field(field, index)
                    end.compact

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
                    end.compact

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

                  name =
                    field["name"] ||
                    field["label"] ||
                    field["key"] ||
                    "Field #{index + 1}"

                  key =
                    field["key"] ||
                    field["name"] ||
                    "field_#{index + 1}"

                  {
                    id: field["id"] ||
                      field["key"] ||
                      field["name"] ||
                      "field_#{index + 1}",

                    name: name,

                    key: key,

                    label:
                      field["label"] ||
                      field["name"] ||
                      field["key"] ||
                      "Field #{index + 1}",

                    type:
                      field["type"] ||
                      field["field_type"] ||
                      "text",

                    required:
                      boolean_from_hash(
                        field,
                        "required",
                        false
                      ),

                    active:
                      boolean_from_hash(
                        field,
                        "active",
                        true
                      ),

                    description: field["description"],

                    placeholder: field["placeholder"],

                    default: field["default"],

                    options:
                      normalize_options(
                        field["options"]
                      ),

                    metadata:
                      field["metadata"].is_a?(Hash) ?
                        field["metadata"] :
                        {}
                  }.compact
                end

                def normalize_options(options)
                  case options
                  when Array
                    options
                  when Hash
                    options.map do |key, value|
                      {
                        "label" => key.to_s,
                        "value" => value
                      }
                    end
                  else
                    []
                  end
                end

                # ---------------------------------------------------------
                # FIELD COUNTS
                # ---------------------------------------------------------

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

                # ---------------------------------------------------------
                # TAGS
                # ---------------------------------------------------------

                def normalized_tags
                  raw_tags =
                    if definition.respond_to?(:tags)
                      definition.tags
                    elsif definition.respond_to?(:keywords)
                      definition.keywords
                    else
                      definition_json_value(
                        "tags",
                        fallback: []
                      )
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

                # ---------------------------------------------------------
                # POPULARITY
                # ---------------------------------------------------------

                def normalized_popularity
                  if definition.respond_to?(:popularity)
                    raw_value = definition.popularity

                    return raw_value.to_i unless raw_value.nil?
                  end

                  definition_json_value(
                    "popularity",
                    fallback: 0
                  ).to_i
                end

                # ---------------------------------------------------------
                # NEW FLAG
                #
                # Your database uses `library_new`, not `new`.
                # ---------------------------------------------------------

                def normalized_new
                  if definition.respond_to?(:library_new)
                    return ActiveModel::Type::Boolean.new.cast(
                      definition.library_new
                    )
                  end

                  if definition.respond_to?(:new_record)
                    return ActiveModel::Type::Boolean.new.cast(
                      definition.new_record
                    )
                  end

                  if definition.respond_to?(:new)
                    return ActiveModel::Type::Boolean.new.cast(
                      definition.new
                    )
                  end

                  false
                end

                # ---------------------------------------------------------
                # METADATA
                # ---------------------------------------------------------

                def normalized_metadata
                  raw_metadata =
                    if definition.respond_to?(:metadata)
                      definition.metadata
                    elsif definition.respond_to?(:settings)
                      definition.settings
                    else
                      {}
                    end

                  raw_metadata =
                    definition_json_value(
                      "metadata",
                      fallback: raw_metadata
                    ) if !raw_metadata.is_a?(Hash) ||
                         raw_metadata.empty?

                  raw_metadata.is_a?(Hash) ? raw_metadata : {}
                end

                # ---------------------------------------------------------
                # DEFINITION JSON
                # ---------------------------------------------------------

                def definition_json_value(key, fallback: nil)
                  return fallback unless definition.respond_to?(:definition_json)

                  json = definition.definition_json

                  return fallback unless json.is_a?(Hash)

                  value =
                    json[key] ||
                    json[key.to_sym]

                  value.nil? ? fallback : value
                end

                # ---------------------------------------------------------
                # SCHEMA FALLBACK
                # ---------------------------------------------------------

                def extract_fields_from_schema(schema)
                  return [] unless schema.is_a?(Hash)

                  schema["fields"] ||
                    schema[:fields] ||
                    []
                end

                # ---------------------------------------------------------
                # HASH / BOOLEAN HELPERS
                # ---------------------------------------------------------

                def boolean_from_hash(hash, key, fallback)
                  value =
                    hash[key] ||
                    hash[key.to_sym]

                  return fallback if value.nil?

                  ActiveModel::Type::Boolean.new.cast(value)
                end

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