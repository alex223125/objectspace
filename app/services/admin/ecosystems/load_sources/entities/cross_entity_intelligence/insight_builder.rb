# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class CrossEntityIntelligence
        class InsightBuilder

          def self.call(
            entity:,
            relationships:,
            activity:,
            evolution:
          )
            new(
              entity: entity,
              relationships: relationships,
              activity: activity,
              evolution: evolution
            ).call
          end

          def initialize(
            entity:,
            relationships:,
            activity:,
            evolution:
          )
            @entity = entity
            @relationships = relationships
            @activity = activity
            @evolution = evolution
          end

          def call
            [].tap do |insights|
              add_relationship_insight(insights)
              add_activity_insight(insights)
              add_evolution_insight(insights)
              add_quality_insight(insights)
            end
          end

          private

          attr_reader \
            :entity,
            :relationships,
            :activity,
            :evolution

          def add_relationship_insight(insights)
            count =
              relationships[:relationships].length

            return if count.zero?

            insights << {
              type: "relationship_cluster",
              severity: "info",
              title: "Related entity cluster detected",
              description:
                "#{count} entities share structural characteristics with this entity.",
              value: count
            }
          end

          def add_activity_insight(insights)
            current =
              activity[:current]

            return unless current

            if current[:activity_level] == "high"
              insights << {
                type: "activity_hotspot",
                severity: "attention",
                title: "High activity entity",
                description:
                  "This entity has significant recent editorial activity.",
                value:
                  current[:recent_event_count]
              }
            end
          end

          def add_evolution_insight(insights)
            current =
              evolution[:current]

            return unless current

            if current[:evolution_level] == "high"
              insights << {
                type: "high_evolution",
                severity: "info",
                title: "Highly evolved entity",
                description:
                  "This entity has accumulated a substantial version history.",
                value:
                  current[:version_count]
              }
            end
          end

          def add_quality_insight(insights)
            return if entity.complete?

            issues =
              entity.quality_issues

            insights << {
              type: "quality_attention",
              severity: "warning",
              title: "Quality attention required",
              description:
                issues.first(3).join(" "),
              value:
                issues.length
            }
          end

        end
      end
    end
  end
end