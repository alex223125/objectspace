# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class MissionEngine
            def initialize(entity: nil)
              @entity = entity
            end

            def call
              missions = [
                discover_connected_entity,
                cross_type_explorer,
                ecosystem_hub_hunt,
                relationship_deep_dive
              ]

              missions.compact
            end

            private

            attr_reader :entity

            def discover_connected_entity
              return nil unless entity

              recommendation = recommendations.first

              return nil unless recommendation

              {
                id: "discover-connected",
                type: "discovery",
                icon: "🧭",
                title: "Discover a connection",
                description: "Explore an entity connected to your current investigation.",
                target: recommendation[:name],
                reward: 25,
                difficulty: "easy",
                action: "discover",
                target_entity_id: recommendation[:id],
                target_entity_type: recommendation[:type]
              }
            end

            def cross_type_explorer
              return nil unless entity

              candidate = recommendations.find do |recommendation|
                recommendation[:type].to_s != entity.class.name.demodulize.underscore
              end

              return nil unless candidate

              {
                id: "cross-type-explorer",
                type: "exploration",
                icon: "🗺️",
                title: "Cross the ecosystem",
                description: "Move from this entity into another ecosystem category.",
                target: candidate[:name],
                reward: 40,
                difficulty: "medium",
                action: "discover",
                target_entity_id: candidate[:id],
                target_entity_type: candidate[:type]
              }
            end

            def ecosystem_hub_hunt
              return nil unless entity

              {
                id: "hub-hunt",
                type: "investigation",
                icon: "🔥",
                title: "Find an ecosystem hub",
                description: "Look for a highly connected entity and investigate its neighborhood.",
                reward: 60,
                difficulty: "hard",
                action: "hub"
              }
            end

            def relationship_deep_dive
              return nil unless entity
              return nil unless EntityAdapter.new(entity).relationship_neighbors.any?

              {
                id: "relationship-deep-dive",
                type: "research",
                icon: "🔎",
                title: "Follow the evidence",
                description: "Inspect a persisted relationship and continue the investigation.",
                reward: 50,
                difficulty: "medium",
                action: "relationship"
              }
            end

            def recommendations
              @recommendations ||= RecommendationEngine
                                     .new(entity: entity, limit: 8)
                                     .call
            end
          end
        end
      end
    end
  end
end