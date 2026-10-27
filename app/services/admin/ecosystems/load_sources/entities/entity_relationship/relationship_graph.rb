# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipGraph
            DEFAULT_LIMIT = 60

            def self.call(entity: nil, entities: nil, limit: DEFAULT_LIMIT)
              new(
                entity: entity,
                entities: entities,
                limit: limit
              ).call
            end

            def initialize(entity:, entities:, limit:)
              @entity = entity
              @entities = Array(entities).compact
              @limit = limit.to_i.clamp(1, 200)
            end

            def call
              relationships =
                if @entity.present?
                  relationships_for_entity
                else
                  relationships_for_entities
                end

              nodes = build_nodes(relationships)

              {
                focus_entity_id: @entity&.id,
                nodes: nodes,
                edges: build_edges(relationships),
                relationship_count: relationships.length,
                node_count: nodes.length
              }
            end

            private

            def relationship_scope
              Ecosystems::LoadSources::Entity::EntityRelationship
                .visible
                .includes(
                  :source_entity,
                  :target_entity
                )
                .ordered_by_confidence
                .limit(@limit)
            end

            def relationships_for_entity
              relationship_scope.where(
                "source_entity_id = :id OR target_entity_id = :id",
                id: @entity.id
              ).to_a
            end

            def relationships_for_entities
              ids = @entities.map(&:id).compact.uniq

              return [] if ids.empty?

              relationship_scope.where(
                source_entity_id: ids,
                target_entity_id: ids
              ).to_a
            end

            def build_nodes(relationships)
              entity_map = {}

              @entities.each do |entity|
                entity_map[entity.id] = entity
              end

              relationships.each do |relationship|
                entity_map[
                  relationship.source_entity_id
                ] ||= relationship.source_entity

                entity_map[
                  relationship.target_entity_id
                ] ||= relationship.target_entity
              end

              entity_map.values.map do |entity|
                {
                  id: entity.id,
                  name: entity.name,
                  slug: entity.slug,
                  summary: entity.summary,
                  scope: entity.scope,
                  status: entity.status,
                  workflow_state: entity.workflow_state,
                  health_score:
                    entity.respond_to?(:health_score) ?
                      entity.health_score :
                      nil,
                  focus:
                    @entity.present? &&
                      entity.id == @entity.id
                }
              end
            end

            def build_edges(relationships)
              relationships.map do |relationship|
                {
                  id: relationship.id,
                  source: relationship.source_entity_id,
                  target: relationship.target_entity_id,
                  kind: relationship.relationship_kind,
                  confidence:
                    relationship.confidence.to_f,
                  confidence_percent:
                    relationship.confidence_percent,
                  state: relationship.state,
                  weight:
                    relationship.intelligence_weight
                }
              end
            end

          end
        end
      end
    end
  end
end
