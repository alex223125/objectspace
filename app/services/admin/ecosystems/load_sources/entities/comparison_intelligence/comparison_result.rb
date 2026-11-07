
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ComparisonResult
            DEFAULTS = {
              total_changes: 0,
              reviewed_changes: 0,
              remaining_changes: 0,
              change_density: 0,
              evolution_score: 0,
              type_breakdown: {},
              path_breakdown: {},
              attention: [],
              highlights: [],
              movement: {},
              balance: {},
              filtered_changes: [],
              filtered_total: 0,
              pagination: {},
              filters: {},
              available_types: [],
              available_risks: []
            }.freeze

            def initialize(attributes = {})
              values = DEFAULTS.merge(
                attributes.to_h.deep_symbolize_keys
              )

              values.each do |key, value|
                instance_variable_set(:"@#{key}", value)
              end
            end

            DEFAULTS.each_key do |attribute|
              attr_reader attribute
            end

            def to_h
              DEFAULTS.keys.index_with do |key|
                public_send(key)
              end
            end

            def empty?
              total_changes.zero?
            end

            def filtered?
              filtered_total != total_changes
            end

            def completion_percentage
              return 100 if total_changes.zero?

              ((reviewed_changes.to_f / total_changes) * 100).round
            end

            def review_progress
              {
                reviewed: reviewed_changes,
                remaining: remaining_changes,
                total: total_changes,
                percentage: completion_percentage
              }
            end
          end
        end
      end
    end
  end
end