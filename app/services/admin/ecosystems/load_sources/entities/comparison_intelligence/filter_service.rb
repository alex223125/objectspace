
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class FilterService
            CHANGE_TYPES = %w[changed moved added removed warning].freeze
            RISK_LEVELS = %w[low medium high critical].freeze
            SORT_FIELDS = %w[path type risk magnitude id].freeze

            def initialize(changes:)
              @changes = Array(changes)
            end

            def call(filters: {})
              options = filters.to_h.stringify_keys
              results = @changes.map { |item| item.to_h.stringify_keys }

              results = filter_type(results, options["type"])
              results = filter_risk(results, options["risk"])
              results = filter_reviewed(results, options["reviewed"])
              results = filter_path(results, options["path"])
              results = filter_query(results, options["query"])

              sort_field = options["sort"].to_s
              sort_field = "path" unless SORT_FIELDS.include?(sort_field)

              direction = options["direction"].to_s == "desc" ? -1 : 1

              results = results.sort_by do |item|
                value = item[sort_field]
                sortable_value = sort_field == "magnitude" ? value.to_f : value.to_s.downcase
                [sortable_value, item["id"].to_s]
              end

              results.reverse! if direction.negative?

              {
                changes: results,
                total: results.length,
                filters: options.slice(
                  "type", "risk", "reviewed", "path",
                  "query", "sort", "direction"
                )
              }
            end

            private

            def filter_type(items, value)
              return items if value.blank? || value.to_s == "all"
              return items unless CHANGE_TYPES.include?(value.to_s)

              items.select { |item| item["type"].to_s == value.to_s }
            end

            def filter_risk(items, value)
              return items if value.blank? || value.to_s == "all"
              return items unless RISK_LEVELS.include?(value.to_s)

              items.select { |item| item["risk"].to_s == value.to_s }
            end

            def filter_reviewed(items, value)
              return items if value.blank? || value.to_s == "all"

              expected = ActiveModel::Type::Boolean.new.cast(value)
              items.select do |item|
                ActiveModel::Type::Boolean.new.cast(item["reviewed"]) == expected
              end
            end

            def filter_path(items, value)
              return items if value.blank?

              needle = value.to_s.downcase
              items.select { |item| item["path"].to_s.downcase.include?(needle) }
            end

            def filter_query(items, value)
              return items if value.blank?

              needle = value.to_s.downcase

              items.select do |item|
                item.values.any? { |field| field.to_s.downcase.include?(needle) }
              end
            end
          end
        end
      end
    end
  end
end