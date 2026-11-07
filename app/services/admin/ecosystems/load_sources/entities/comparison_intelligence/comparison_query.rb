
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ComparisonQuery
            SEVERITY = {
              "critical" => 4,
              "high" => 3,
              "warning" => 2,
              "medium" => 2,
              "info" => 1,
              "low" => 0
            }.freeze

            def initialize(changes:, context:)
              @changes = Array(changes).map { |item| normalize_change(item) }
              @context = context
            end

            def call
              filtered = filter_changes(changes)
              sorted = sort_changes(filtered)

              {
                changes: paginate(sorted),
                total: sorted.length,
                page: context.page,
                per_page: context.per_page,
                total_pages: (sorted.length.to_f / context.per_page).ceil,
                filters: context.cache_attributes,
                available_types: changes.map { |item| item[:type] }.uniq.sort,
                available_risks: changes.map { |item| item[:risk] }.uniq.sort
              }
            end

            private

            attr_reader :changes, :context

            def normalize_change(item)
              attributes =
                if item.respond_to?(:to_h)
                  item.to_h.stringify_keys
                else
                  {}
                end

              {
                id: attributes["id"].presence || attributes["key"].presence,
                type: attributes["type"].to_s.downcase.presence || "changed",
                path: attributes["path"].to_s.presence || "Unknown path",
                risk: attributes["risk"].to_s.downcase.presence || "low",
                reviewed: ActiveModel::Type::Boolean.new.cast(
                  attributes["reviewed"]
                ),
                magnitude: [[attributes["magnitude"].to_i, 1].max, 100].min,
                attributes: attributes
              }
            end

            def filter_changes(items)
              items.select do |item|
                matches_query?(item) &&
                  matches_type?(item) &&
                  matches_risk?(item) &&
                  matches_reviewed?(item)
              end
            end

            def matches_query?(item)
              return true if context.query.blank?

              haystack = [
                item[:id],
                item[:type],
                item[:path],
                item[:risk],
                item[:attributes].to_json
              ].compact.join(" ").downcase

              haystack.include?(context.query.downcase)
            end

            def matches_type?(item)
              context.types.empty? || context.types.include?(item[:type])
            end

            def matches_risk?(item)
              context.risk_levels.empty? ||
                context.risk_levels.include?(item[:risk])
            end

            def matches_reviewed?(item)
              context.reviewed.nil? || item[:reviewed] == context.reviewed
            end

            def sort_changes(items)
              direction = context.direction == "asc" ? 1 : -1

              items.sort_by do |item|
                value =
                  case context.sort
                  when "magnitude"
                    item[:magnitude]
                  when "path"
                    item[:path].downcase
                  when "type"
                    item[:type]
                  when "reviewed"
                    item[:reviewed] ? 1 : 0
                  else
                    SEVERITY.fetch(item[:risk], 0)
                  end

                value.is_a?(Numeric) ? value * direction : value.to_s
              end
            end

            def paginate(items)
              items.slice(context.pagination_offset, context.per_page) || []
            end
          end
        end
      end
    end
  end
end