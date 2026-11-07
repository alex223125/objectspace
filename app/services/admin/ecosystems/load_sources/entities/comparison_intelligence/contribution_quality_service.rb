
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ContributionQualityService
            WEIGHTS = {
              accepted_changes: 10,
              evidence_supported_changes: 15,
              resolved_contradictions: 20,
              verified_citations: 5,
              completed_reviews: 8
            }.freeze

            def initialize(contribution:)
              @contribution = contribution || {}
            end

            def call
              data = contribution.respond_to?(:to_h) ? contribution.to_h : {}
              data = data.stringify_keys

              breakdown = WEIGHTS.each_with_object({}) do |(key, weight), result|
                count = [data[key.to_s].to_i, 0].max
                result[key] = {
                  count: count,
                  points: count * weight
                }
              end

              total = breakdown.values.sum { |item| item[:points] }

              {
                total_points: total,
                level: level_for(total),
                breakdown: breakdown,
                scoring_policy: WEIGHTS,
                note: "Points measure recorded quality signals, not the objective truth of an edit."
              }
            end

            private

            attr_reader :contribution

            def level_for(points)
              case points
              when 500.. then "editorial_champion"
              when 250..499 then "research_expert"
              when 100..249 then "trusted_contributor"
              when 25..99 then "active_reviewer"
              else "contributor"
              end
            end
          end
        end
      end
    end
  end
end