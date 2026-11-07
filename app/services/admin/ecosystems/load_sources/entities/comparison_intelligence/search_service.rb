
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class SearchService
            DEFAULT_LIMIT = 50
            MAX_LIMIT = 200

            def initialize(changes:)
              @changes = Array(changes)
            end

            def call(query:, limit: DEFAULT_LIMIT)
              term = query.to_s.strip
              return empty_result if term.blank?

              normalized = term.downcase
              bounded_limit = [[limit.to_i, 1].max, MAX_LIMIT].min

              matches = @changes.filter_map do |change|
                attributes = change.to_h.stringify_keys
                searchable = searchable_text(attributes)

                next unless searchable.include?(normalized)

                {
                  change: attributes,
                  matched_fields: matching_fields(attributes, normalized)
                }
              end

              {
                query: term,
                total: matches.length,
                results: matches.first(bounded_limit),
                truncated: matches.length > bounded_limit
              }
            end

            private

            def empty_result
              { query: "", total: 0, results: [], truncated: false }
            end

            def searchable_text(attributes)
              attributes.slice(
                "id",
                "key",
                "path",
                "type",
                "risk",
                "title",
                "description",
                "before",
                "after",
                "old_value",
                "new_value"
              ).values.map { |value| value.to_s.downcase }.join(" ")
            end

            def matching_fields(attributes, term)
              attributes.filter_map do |key, value|
                key if value.to_s.downcase.include?(term)
              end
            end
          end
        end
      end
    end
  end
end