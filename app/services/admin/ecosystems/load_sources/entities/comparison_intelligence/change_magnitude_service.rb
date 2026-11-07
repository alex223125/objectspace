
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ChangeMagnitudeService
            TYPE_WEIGHTS = {
              "added" => 4,
              "removed" => 7,
              "changed" => 3,
              "moved" => 5,
              "warning" => 8
            }.freeze

            def call(change)
              attributes = change.to_h.deep_symbolize_keys

              type = attributes[:type].to_s
              before = attributes[:before]
              after = attributes[:after]
              field_type = attributes[:field_type].to_s

              reasons = []
              score = TYPE_WEIGHTS.fetch(type, 3)

              if attributes[:identity_field]
                score += 5
                reasons << "Identity-related field"
              end

              if field_type.include?("relationship")
                score += 3
                reasons << "Relationship field"
              end

              if before.is_a?(String) && after.is_a?(String)
                score += text_delta(before, after)
                reasons << "Text length changed"
              elsif before.is_a?(Hash) || after.is_a?(Hash) ||
                before.is_a?(Array) || after.is_a?(Array)
                score += 3
                reasons << "Structured value changed"
              end

              score = [[score, 1].max, 100].min

              attributes.merge(
                magnitude: score,
                magnitude_label: label_for(score),
                magnitude_reasons: reasons
              )
            end

            private

            def text_delta(before, after)
              delta = (after.length - before.length).abs
              [[(delta / 100.0).ceil, 0].max, 10].min
            end

            def label_for(score)
              case score
              when 1..3 then "Low"
              when 4..7 then "Moderate"
              when 8..14 then "High"
              else "Very high"
              end
            end
          end
        end
      end
    end
  end
end