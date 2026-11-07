
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RiskAssessmentService
            def call(change)
              attributes = change.to_h.deep_symbolize_keys
              reasons = []

              score = 0
              type = attributes[:type].to_s
              magnitude = attributes[:magnitude].to_i

              if attributes[:identity_field]
                score += 35
                reasons << "Identity field changed"
              end

              if type == "removed"
                score += 25
                reasons << "Value removed"
              end

              if type == "warning"
                score += 35
                reasons << "Comparison warning"
              end

              if attributes[:classification].to_s == "relationship"
                score += 15
                reasons << "Relationship impact possible"
              end

              if magnitude >= 15
                score += 15
                reasons << "High change magnitude"
              end

              score = [score, 100].min

              attributes.merge(
                risk_score: score,
                risk: level_for(score),
                risk_reasons: reasons,
                review_required: score >= 35 ||
                  !!attributes[:review_required]
              )
            end

            private

            def level_for(score)
              case score
              when 0..19 then "low"
              when 20..44 then "medium"
              when 45..69 then "high"
              else "critical"
              end
            end
          end
        end
      end
    end
  end
end