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
                  {
                    id: definition.id.to_s,
                    slug: value(:slug, fallback: definition.id.to_s),
                    name: value(:name, fallback: value(:title, fallback: "Definition")),
                    title: value(:title, fallback: value(:name, fallback: "Definition")),

                    category: value(:category, fallback: "General"),
                    subcategory: value(:subcategory),

                    description: value(
                      :description,
                      fallback: "Production-ready definition template."
                    ),

                    icon: value(:icon, fallback: "✦"),

                    version: normalized_version,

                    fields: normalized_fields,

                    field_count: normalized_fields.length,

                    required_count: required_fields_count,

                    active_count: active_fields_count,

                    tags: normalized_tags,

                    popularity: normalized_popularity,

                    featured: boolean_value(:featured),
                    new: boolean_value(:new, fallback: false),

                    metadata: normalized_metadata
                  }
                end

                private

                attr_reader :definition

                def value(attribute, fallback: nil)
                  return fallback unless definition.respond_to?(attribute)

                  result = definition.public_send(attribute)

                  result.nil? || result.to_s.strip.empty? ? fallback : result
                end

                def boolean_value(attribute, fallback: false)
                  return fallback unless definition.respond_to?(attribute)

                  value = definition.public_send(attribute)

                  return fallback if value.nil?

                  ActiveModel::Type::Boolean.new.cast(value)
                end

                def normalized_version
                  version = value(:version, fallback: 1)

                  if version.respond_to?(:to_i)
                    version.to_i
                  else
                    1
                  end
                end

                def normalized_fields
                  raw_fields =
                    if definition.respond_to?(:fields)
                      definition.fields
                    elsif definition.respond_to?(:field_definitions)
                      definition.field_definitions
                    elsif definition.respond_to?(:schema)
                      extract_fields_from_schema(definition.schema)
                    else
                      []
                    end

                  normalize_fields(raw_fields)
                end

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
                          field.merge("name" => (field["name"] || key)),
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
                    id: field["id"] || field["key"] || field["name"] || "field_#{index + 1}",

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

                    required: boolean_from_hash(field, "required", false),

                    active: boolean_from_hash(field, "active", true),

                    description: field["description"],

                    placeholder: field["placeholder"],

                    default: field["default"],

                    options: field["options"] || [],

                    metadata: field["metadata"] || {}
                  }.compact
                end

                def required_fields_count
                  normalized_fields.count do |field|
                    field[:required] == true
                  end
                end

                def active_fields_count
                  normalized_fields.count do |field|
                    field[:active] != false
                  end
                end

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
                    raw_tags.map(&:to_s).reject(&:blank?).uniq
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

                def normalized_popularity
                  return 0 unless definition.respond_to?(:popularity)

                  value = definition.popularity

                  return 0 if value.nil?

                  value.to_i
                end

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

                def extract_fields_from_schema(schema)
                  return [] unless schema.is_a?(Hash)

                  schema["fields"] ||
                    schema[:fields] ||
                    []
                end

                def boolean_from_hash(hash, key, fallback)
                  value = hash[key]

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