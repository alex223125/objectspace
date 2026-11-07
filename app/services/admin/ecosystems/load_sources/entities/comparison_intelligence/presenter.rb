
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class Presenter
            def initialize(result:, changes: [], metadata: {})
              @result = result.to_h.symbolize_keys
              @changes = Array(changes)
              @metadata = metadata.to_h.symbolize_keys
            end

            def call
              total = integer(:total_changes)
              reviewed = integer(:reviewed_changes)
              remaining = integer(:remaining_changes)

              {
                metadata: safe_metadata,
                summary: {
                  total_changes: total,
                  reviewed_changes: reviewed,
                  remaining_changes: remaining,
                  completion_percentage: percentage(reviewed, total),
                  evolution_score: bounded_score(:evolution_score),
                  change_density: bounded_score(:change_density)
                },
                distribution: {
                  types: hash_value(:type_breakdown),
                  paths: hash_value(:path_breakdown),
                  movement: hash_value(:movement),
                  balance: hash_value(:balance)
                },
                risk: {
                  identity_risk: string_value(:identity_risk, "low"),
                  attention_score: bounded_score(:attention_score),
                  attention_level: string_value(:attention_level, "low"),
                  items: array_value(:attention)
                },
                highlights: array_value(:highlights),
                changes: @changes.map { |item| item.to_h.stringify_keys },
                generated_at: Time.current.iso8601
              }
            end

            private

            def safe_metadata
              @metadata.slice(
                :entity_id,
                :entity_name,
                :old_version_id,
                :new_version_id,
                :old_version_number,
                :new_version_number
              )
            end

            def integer(key)
              Integer(@result.fetch(key, 0) || 0)
            rescue ArgumentError, TypeError
              0
            end

            def bounded_score(key)
              [[integer(key), 0].max, 100].min
            end

            def percentage(numerator, denominator)
              return 100 if denominator.zero? && numerator.zero?
              return 0 if denominator.zero?

              [[((numerator.to_f / denominator) * 100).round, 0].max, 100].min
            end

            def hash_value(key)
              value = @result.fetch(key, {})
              value.is_a?(Hash) ? value : {}
            end

            def array_value(key)
              value = @result.fetch(key, [])
              value.is_a?(Array) ? value : []
            end

            def string_value(key, fallback)
              value = @result[key]
              value.present? ? value.to_s : fallback
            end
          end
        end
      end
    end
  end
end