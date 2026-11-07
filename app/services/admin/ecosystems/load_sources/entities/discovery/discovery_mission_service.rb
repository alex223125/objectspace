# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class DiscoveryMissionService
            def initialize(entity)
              @entity = entity
            end

            def generate!
              profile = explorer_profile

              recommendations = DiscoveryEngine
                                  .new(entity, limit: 5)
                                  .call[:recommendations]

              recommendations.each_with_index do |recommendation, index|
                mission_type = mission_type_for(recommendation)

                entity.ecosystem_discovery_missions.find_or_create_by!(
                  mission_type: mission_type
                ) do |mission|
                  mission.title = mission_title(index)
                  mission.description = mission_description(recommendation)
                  mission.xp_reward = 20 + (index * 10)
                  mission.target = 1
                  mission.metadata = {
                    target_entity_id: recommendation[:id],
                    relationship: recommendation[:relationship],
                    score: recommendation[:score]
                  }
                end
              end

              profile
            end

            def complete!(mission)
              return mission unless mission.entity_id == entity.id

              transaction do
                mission.complete!
                explorer_profile.add_xp!(mission.xp_reward)
                explorer_profile.increment!(:discoveries_count)
              end

              mission
            end

            private

            attr_reader :entity

            def explorer_profile
              entity.ecosystem_explorer_profile ||
                entity.create_ecosystem_explorer_profile!
            end

            def mission_type_for(recommendation)
              case recommendation[:action]
              when "follow_evolution"
                "follow_evolution"
              when "compare"
                "compare_related"
              else
                "explore_connection"
              end
            end

            def mission_title(index)
              [
                "Explore a strong connection",
                "Discover a related entity",
                "Expand the ecosystem"
              ][index] || "Continue exploring"
            end

            def mission_description(recommendation)
              "Investigate #{recommendation[:title]} and understand its relationship to the current entity."
            end
          end
        end
      end
    end
  end
end