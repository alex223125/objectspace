# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class DiscoveryScore
            RELATIONSHIP_WEIGHTS = {
              "depends_on" => 1.00,
              "evolves_to" => 0.98,
              "solves" => 0.95,
              "uses" => 0.90,
              "implements" => 0.90,
              "related_to" => 0.72,
              "similar_to" => 0.68,
              "references" => 0.62,
              "associated_with" => 0.55
            }.freeze

            def self.call(**attributes)
              new(**attributes).call
            end

            def initialize(
              confidence:,
              relationship_kind:,
              activity_score: 0.0,
              reciprocal: false,
              novelty: 0.5,
              already_explored: false
            )
              @confidence = normalize(confidence)
              @relationship_kind = relationship_kind.to_s
              @activity_score = normalize(activity_score)
              @reciprocal = reciprocal
              @novelty = normalize(novelty)
              @already_explored = already_explored
            end

            def call
              score =
                (@confidence * 35.0) +
                  (relationship_strength * 25.0) +
                  (@activity_score * 15.0) +
                  (reciprocal_bonus) +
                  (@novelty * 15.0) +
                  (exploration_bonus)

              [[score.round, 100].min, 0].max
            end

            private

            def relationship_strength
              RELATIONSHIP_WEIGHTS.fetch(
                @relationship_kind,
                RELATIONSHIP_WEIGHTS["related_to"]
              )
            end

            def reciprocal_bonus
              @reciprocal ? 7.0 : 0.0
            end

            def exploration_bonus
              @already_explored ? -8.0 : 8.0
            end

            def normalize(value)
              number = value.to_f

              if number > 1.0
                number / 100.0
              else
                number.clamp(0.0, 1.0)
              end
            end
          end
        end
      end
    end
  end
end