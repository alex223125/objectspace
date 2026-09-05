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
              {
                changed: changed?,

                summary: {
                  added: added_fields.length,
                  removed: removed_fields.length,
                  modified: modified_fields.length,
                  unchanged: unchanged_fields.length,
                  total: all_fields.length
                },

                # --------------------------------------------------------
                # IMPORTANT:
                #
                # This is the normalized collection consumed by the
                # Stimulus controller and compare.html.erb.
                # --------------------------------------------------------

                fields: all_fields,

                # Keep the individual collections available too.
                added: added_fields,
                removed: removed_fields,
                modified: modified_fields,
                unchanged: unchanged_fields,

                # Keep raw definitions for debugging / other UI.
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

              definition
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
                field.is_a?(Hash)
              end
            end


            # ============================================================
            # INDEX FIELDS BY NAME
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
            # ADDED
            # ============================================================

            def added_fields
              @added_fields ||=
                fields_b_by_name
                  .keys
                  .difference(
                    fields_a_by_name.keys
                  )
                  .map do |name|

                  {
                    name: name,
                    change_type: "added",
                    field: fields_b_by_name[name],

                    version_a: nil,
                    version_b: fields_b_by_name[name],

                    changes: {}
                  }

                end
            end


            # ============================================================
            # REMOVED
            # ============================================================

            def removed_fields
              @removed_fields ||=
                fields_a_by_name
                  .keys
                  .difference(
                    fields_b_by_name.keys
                  )
                  .map do |name|

                  {
                    name: name,
                    change_type: "removed",
                    field: fields_a_by_name[name],

                    version_a: fields_a_by_name[name],
                    version_b: nil,

                    changes: {}
                  }

                end
            end


            # ============================================================
            # MODIFIED
            # ============================================================

            def modified_fields
              @modified_fields ||=
                fields_a_by_name
                  .keys
                  .intersection(
                    fields_b_by_name.keys
                  )
                  .filter_map do |name|

                  field_a =
                    fields_a_by_name[name]

                  field_b =
                    fields_b_by_name[name]

                  changes =
                    compare_field(
                      field_a,
                      field_b
                    )

                  next if changes.empty?

                  {
                    name: name,
                    change_type: "changed",

                    field: field_b,

                    version_a: field_a,
                    version_b: field_b,

                    changes: changes
                  }

                end
            end


            # ============================================================
            # UNCHANGED
            # ============================================================

            def unchanged_fields
              @unchanged_fields ||=
                fields_a_by_name
                  .keys
                  .intersection(
                    fields_b_by_name.keys
                  )
                  .filter_map do |name|

                  field_a =
                    fields_a_by_name[name]

                  field_b =
                    fields_b_by_name[name]

                  changes =
                    compare_field(
                      field_a,
                      field_b
                    )

                  next unless changes.empty?

                  {
                    name: name,
                    change_type: "unchanged",

                    field: field_b,

                    version_a: field_a,
                    version_b: field_b,

                    changes: {}
                  }

                end
            end


            # ============================================================
            # ALL FIELDS
            # ============================================================

            def all_fields
              @all_fields ||=
                (
                  added_fields +
                    removed_fields +
                    modified_fields +
                    unchanged_fields
                ).sort_by do |field|

                  field[:name].to_s.downcase
                end
            end


            # ============================================================
            # FIELD COMPARISON
            # ============================================================

            def compare_field(field_a, field_b)
              COMPARABLE_ATTRIBUTES.each_with_object({}) do |attribute, changes|

                value_a =
                  normalize_value(
                    field_a[attribute]
                  )

                value_b =
                  normalize_value(
                    field_b[attribute]
                  )

                next if value_a == value_b

                changes[attribute] = {
                  from: value_a,
                  to: value_b
                }

              end
            end


            # ============================================================
            # VALUE NORMALIZATION
            # ============================================================

            def normalize_value(value)
              case value

              when Array
                value

              when Hash
                value

              when nil
                nil

              when TrueClass, FalseClass
                value

              else
                value.to_s

              end
            end


            # ============================================================
            # OVERALL CHANGE STATE
            # ============================================================

            def changed?
              added_fields.any? ||
                removed_fields.any? ||
                modified_fields.any?
            end

          end

        end
      end
    end
  end
end
