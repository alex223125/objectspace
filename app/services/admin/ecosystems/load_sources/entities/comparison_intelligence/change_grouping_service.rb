
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ChangeGroupingService
            ALLOWED_GROUPINGS = %w[
              path type classification field_type risk
            ].freeze

            def call(changes:, by: :path)
              key = by.to_s
              key = "path" unless ALLOWED_GROUPINGS.include?(key)

              grouped = Array(changes).group_by do |change|
                attributes = change.to_h.deep_symbolize_keys
                attributes[key.to_sym].presence || "unclassified"
              end

              grouped
                .sort_by { |group_key, items| [-items.length, group_key.to_s] }
                .map do |group_key, items|
                {
                  key: group_key.to_s,
                  label: group_key.to_s.tr("_", " ").capitalize,
                  count: items.length,
                  reviewed: items.count do |item|
                    item.to_h.deep_symbolize_keys[:reviewed]
                  end,
                  changes: items
                }
              end
            end
          end
        end
      end
    end
  end
end