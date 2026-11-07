# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class CrossEntityIntelligence
        class EvolutionAnalysis

          def self.call(entity:, entities:)
            new(
              entity: entity,
              entities: entities
            ).call
          end

          def initialize(entity:, entities:)
            @entity = entity
            @entities = Array(entities)
          end

          def call
            results = entities.map do |item|
              versions =
                item.entity_versions.to_a

              {
                entity_id: item.id,
                version_count: versions.length,
                first_version:
                  versions.first&.version_number,
                latest_version:
                  versions.last&.version_number,
                evolution_level:
                  evolution_level(versions)
              }
            end

            {
              entities: results,
              current:
                results.find do |item|
                  item[:entity_id] == entity.id
                end
            }
          end

          private

          attr_reader :entity, :entities

          def evolution_level(versions)
            count = versions.length

            case count
            when 10..Float::INFINITY
              "high"
            when 4..9
              "medium"
            when 2..3
              "low"
            else
              "new"
            end
          end

        end
      end
    end
  end
end