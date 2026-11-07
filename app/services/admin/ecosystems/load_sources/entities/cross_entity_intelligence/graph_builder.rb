# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module CrossEntityIntelligence

      class GraphBuilder

        def self.call(entity, limit: 30)
          new(
            entity,
            limit: limit
          ).call
        end

        def initialize(entity, limit:)
          @entity = entity
          @limit = limit.to_i.clamp(1, 100)
        end

        def call
          relationships =
            Ecosystems::LoadSources::Entity::EntityRelationship
              .visible
              .for_entity(entity.id)
              .includes(
                :source_entity,
                :target_entity
              )
              .ordered_by_strength
              .limit(limit)

          nodes = build_nodes(relationships)
          edges = build_edges(relationships)

          {
            nodes: nodes,
            edges: edges,
            root_entity_id: entity.id,
            generated_at: Time.current.iso8601
          }
        end

        private

        attr_reader :entity, :limit

        def build_nodes(relationships)
          entities =
            relationships.flat_map do |relationship|
              [
                relationship.source_entity,
                relationship.target_entity
              ]
            end

          entities << entity

          entities
            .compact
            .uniq(&:id)
            .map do |item|
            {
              id: item.id,
              label: item.name,
              slug: item.slug,
              type: item.entity_type&.name,
              template: item.entity_template&.name,
              scope: item.scope,
              status: item.status,
              health_score:
                item.respond_to?(:health_score) ?
                  item.health_score :
                  nil,
              root: item.id == entity.id
            }
          end
        end

        def build_edges(relationships)
          relationships.map do |relationship|
            {
              id: relationship.id,
              source: relationship.source_entity_id,
              target: relationship.target_entity_id,
              type: relationship.relationship_type,
              label: relationship.label,
              strength: relationship.strength.to_i,
              confidence: relationship.confidence.to_f,
              signals: relationship.evidence_labels
            }
          end
        end

      end

    end
  end
end