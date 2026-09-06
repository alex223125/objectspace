module Services
  module Admin
    module Ecosystems
      module LoadSources
        module EntityTemplates

          class EntityTemplateVersionComparator

            COMPARABLE_ATTRIBUTES = %w[
              type
              label
              required
              description
              options
            ].freeze


            # ============================================================
            # INITIALIZE
            # ============================================================

            def initialize(version_a, version_b)
              @version_a = version_a
              @version_b = version_b
            end


            # ============================================================
            # PUBLIC API
            # ============================================================

            def compare
              fields = comparison_fields

              {
                changed:
                  fields.any? do |field|
                    field[:change_type] != "unchanged"
                  end,

                summary: {
                  added:
                    fields.count do |field|
                      field[:change_type] == "added"
                    end,

                  removed:
                    fields.count do |field|
                      field[:change_type] == "removed"
                    end,

                  changed:
                    fields.count do |field|
                      field[:change_type] == "changed"
                    end,

                  # Keep "modified" for backwards compatibility.
                  modified:
                    fields.count do |field|
                      field[:change_type] == "changed"
                    end,

                  unchanged:
                    fields.count do |field|
                      field[:change_type] == "unchanged"
                    end
                },

                # ========================================================
                # FIELD COMPARISONS
                # ========================================================

                fields: fields,

                # ========================================================
                # BACKWARDS COMPATIBILITY
                # ========================================================

                added:
                  fields.select do |field|
                    field[:change_type] == "added"
                  end,

                removed:
                  fields.select do |field|
                    field[:change_type] == "removed"
                  end,

                modified:
                  fields.select do |field|
                    field[:change_type] == "changed"
                  end,

                unchanged:
                  fields.select do |field|
                    field[:change_type] == "unchanged"
                  end,

                # ========================================================
                # DEFINITION DATA
                # ========================================================

                definition: definition_changes,

                raw: {
                  version_a: definition_a,
                  version_b: definition_b
                }
              }
            end


            private


            # ============================================================
            # DEFINITIONS
            # ============================================================

            def definition_a
              normalize_definition(
                @version_a&.definition
              )
            end


            def definition_b
              normalize_definition(
                @version_b&.definition
              )
            end


            def normalize_definition(definition)
              return {} unless definition.is_a?(Hash)

              deep_stringify_keys(definition)
            end


            def deep_stringify_keys(value)
              case value

              when Hash
                value.each_with_object({}) do |(key, nested_value), result|
                  result[key.to_s] =
                    deep_stringify_keys(nested_value)
                end

              when Array
                value.map do |nested_value|
                  deep_stringify_keys(nested_value)
                end

              else
                value
              end
            end


            # ============================================================
            # FIELDS
            # ============================================================

            def fields_a
              normalize_fields(
                definition_a["fields"]
              )
            end


            def fields_b
              normalize_fields(
                definition_b["fields"]
              )
            end


            def normalize_fields(fields)
              return [] unless fields.is_a?(Array)

              fields.select do |field|
                field.is_a?(Hash) &&
                  field["name"].present?
              end
            end


            # ============================================================
            # INDEX BY NAME
            # ============================================================

            def fields_a_by_name
              @fields_a_by_name ||=
                fields_a.each_with_object({}) do |field, result|

                  name =
                    field["name"]
                      .to_s
                      .strip

                  next if name.blank?

                  result[name] = field
                end
            end


            def fields_b_by_name
              @fields_b_by_name ||=
                fields_b.each_with_object({}) do |field, result|

                  name =
                    field["name"]
                      .to_s
                      .strip

                  next if name.blank?

                  result[name] = field
                end
            end


            # ============================================================
            # ALL COMPARISON FIELDS
            # ============================================================

            def comparison_fields
              @comparison_fields ||= begin

                                       all_names =
                                         (
                                           fields_a_by_name.keys +
                                             fields_b_by_name.keys
                                         ).uniq.sort

                                       all_names.map do |name|

                                         field_a =
                                           fields_a_by_name[name]

                                         field_b =
                                           fields_b_by_name[name]

                                         build_comparison_field(
                                           name,
                                           field_a,
                                           field_b
                                         )

                                       end

                                     end
            end


            # ============================================================
            # BUILD COMPARISON FIELD
            # ============================================================

            def build_comparison_field(
              name,
              field_a,
              field_b
            )

              # ==========================================================
              # ADDED
              # ==========================================================

              if field_a.nil? && field_b.present?

                {
                  name: name,
                  change_type: "added",

                  # The view can use these names.
                  left: nil,
                  right: field_b,

                  # Original names retained for compatibility.
                  version_a: nil,
                  version_b: field_b,

                  version_a_present: false,
                  version_b_present: true,

                  changes: [],

                  version_a_text: nil,
                  version_b_text: field_text(field_b),

                  description:
                    "The field was added in Version B. " \
                      "It did not exist in Version A.",

                  change_summary: [
                    {
                      attribute: "field",
                      type: "added",
                      from: nil,
                      to: field_b
                    }
                  ]
                }


                # ==========================================================
                # REMOVED
                # ==========================================================

              elsif field_a.present? && field_b.nil?

                {
                  name: name,
                  change_type: "removed",

                  # The view can use these names.
                  left: field_a,
                  right: nil,

                  # Original names retained for compatibility.
                  version_a: field_a,
                  version_b: nil,

                  version_a_present: true,
                  version_b_present: false,

                  changes: [],

                  version_a_text: field_text(field_a),
                  version_b_text: nil,

                  description:
                    "The field existed in Version A " \
                      "but was removed in Version B.",

                  change_summary: [
                    {
                      attribute: "field",
                      type: "removed",
                      from: field_a,
                      to: nil
                    }
                  ]
                }


                # ==========================================================
                # BOTH EXIST
                # ==========================================================

              else

                property_changes =
                  compare_field(
                    field_a,
                    field_b
                  )

                change_type =
                  property_changes.empty? ?
                    "unchanged" :
                    "changed"

                {
                  name: name,
                  change_type: change_type,

                  # The view expects these.
                  left: field_a,
                  right: field_b,

                  # Original names retained for compatibility.
                  version_a: field_a,
                  version_b: field_b,

                  version_a_present: true,
                  version_b_present: true,

                  # Array of explicit property changes.
                  changes: property_changes,

                  version_a_text: field_text(field_a),
                  version_b_text: field_text(field_b),

                  description:
                    field_change_description(
                      name,
                      property_changes
                    ),

                  change_summary:
                    property_changes
                }

              end
            end


            # ============================================================
            # FIELD COMPARISON
            # ============================================================

            def compare_field(field_a, field_b)

              COMPARABLE_ATTRIBUTES.each_with_object([]) do |attribute, changes|

                value_a =
                  normalize_value(
                    field_a[attribute]
                  )

                value_b =
                  normalize_value(
                    field_b[attribute]
                  )

                next if values_equal?(value_a, value_b)

                changes << {
                  key: attribute,

                  attribute: attribute,

                  type: "changed",

                  from: value_a,

                  to: value_b,

                  # Names expected by the existing view.
                  left: value_a,
                  right: value_b,

                  description:
                    property_change_description(
                      attribute,
                      value_a,
                      value_b
                    )
                }

              end
            end


            # ============================================================
            # PROPERTY VALUE COMPARISON
            # ============================================================

            def values_equal?(left, right)
              normalize_value(left) == normalize_value(right)
            end


            # ============================================================
            # HUMAN-READABLE FIELD DESCRIPTION
            # ============================================================

            def field_change_description(
              name,
              property_changes
            )

              if property_changes.empty?

                "No properties changed for the #{name.inspect} field."

              else

                changed_properties =
                  property_changes.map do |change|
                    change[:attribute].to_s
                  end

                properties =
                  changed_properties
                    .map(&:humanize)
                    .to_sentence

                "The #{name.inspect} field was modified. " \
                  "Changed #{properties}."

              end
            end


            # ============================================================
            # HUMAN-READABLE PROPERTY DESCRIPTION
            # ============================================================

            def property_change_description(
              attribute,
              value_a,
              value_b
            )

              label =
                attribute.to_s.humanize

              case attribute.to_s

              when "type"

                "The field type changed " \
                  "from #{display_value(value_a)} " \
                  "to #{display_value(value_b)}."

              when "label"

                "The field label changed " \
                  "from #{display_value(value_a)} " \
                  "to #{display_value(value_b)}."

              when "required"

                if value_a == false && value_b == true

                  "The field is now required."

                elsif value_a == true && value_b == false

                  "The field is no longer required."

                else

                  "#{label} changed " \
                    "from #{display_value(value_a)} " \
                    "to #{display_value(value_b)}."

                end

              when "description"

                "The field description changed."

              when "options"

                "The available field options changed."

              else

                "#{label} changed " \
                  "from #{display_value(value_a)} " \
                  "to #{display_value(value_b)}."

              end
            end


            # ============================================================
            # DISPLAY VALUE
            # ============================================================

            def display_value(value)

              case value

              when nil
                "not set"

              when String
                value.present? ? value.inspect : "empty"

              when TrueClass
                "true"

              when FalseClass
                "false"

              when Array, Hash
                value.inspect

              else
                value.to_s
              end

            end


            # ============================================================
            # FIELD DISPLAY DATA
            # ============================================================

            def field_text(field)

              return nil unless field.is_a?(Hash)

              {
                name: field["name"],
                type: field["type"],
                label: field["label"],
                required: field["required"],
                description: field["description"],
                options: field["options"],
                raw: field
              }

            end


            # ============================================================
            # DEFINITION-LEVEL CHANGES
            # ============================================================

            def definition_changes

              keys =
                (
                  definition_a.keys +
                    definition_b.keys
                ).uniq.sort

              keys.each_with_object([]) do |key, changes|

                exists_a =
                  definition_a.key?(key)

                exists_b =
                  definition_b.key?(key)

                value_a =
                  definition_a[key]

                value_b =
                  definition_b[key]

                if !exists_a && exists_b

                  changes << {
                    key: key,
                    type: "added",
                    left: nil,
                    right: value_b,
                    description:
                      "The #{key.humanize.downcase} " \
                        "was added in Version B."
                  }

                elsif exists_a && !exists_b

                  changes << {
                    key: key,
                    type: "removed",
                    left: value_a,
                    right: nil,
                    description:
                      "The #{key.humanize.downcase} " \
                        "was removed in Version B."
                  }

                elsif !values_equal?(value_a, value_b)

                  changes << {
                    key: key,
                    type: "changed",
                    left: value_a,
                    right: value_b,
                    description:
                      "The #{key.humanize.downcase} " \
                        "changed between Version A and Version B."
                  }

                end

              end

            end


            # ============================================================
            # VALUE NORMALIZATION
            # ============================================================

            def normalize_value(value)

              case value

              when Array

                value.map do |item|
                  normalize_value(item)
                end

              when Hash

                deep_stringify_keys(value)

              when nil

                nil

              when TrueClass, FalseClass

                value

              else

                value.to_s

              end

            end

          end

        end
      end
    end
  end
end
