# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class EntityRelationshipGraph

            DEFAULT_LIMIT = 100

            def initialize(entities:, limit: DEFAULT_LIMIT)
              @entities = Array(entities).compact
              @limit = limit.to_i.clamp(1, 500)
            end

            def call
              {
                nodes: nodes,
                edges: edges,
                stats: stats
              }
            end

            private

            attr_reader :entities, :limit

            def entity_ids
              @entity_ids ||=
                entities
                  .map(&:id)
                  .compact
                  .map(&:to_i)
                  .uniq
            end

            def relationships
              return empty_relation if entity_ids.empty?

              ::Ecosystems::LoadSources::Entity::EntityRelationship
                .active
                .where(
                  source_entity_id: entity_ids,
                  target_entity_id: entity_ids
                )
                .includes(
                  :source_entity,
                  :target_entity
                )
                .order(confidence: :desc)
                .limit(limit)
            end

            def empty_relation
              ::Ecosystems::LoadSources::Entity::EntityRelationship
                .none
            end

            def nodes
              entities.map do |entity|
                {
                  id: entity.id,
                  label: entity.name,
                  slug: entity.slug,
                  type: entity.entity_type&.name,
                  scope: entity.scope,
                  status: entity.status,
                  health_score:
                    entity.respond_to?(:health_score) ?
                      entity.health_score :
                      nil
                }
              end
            end

            def edges
              relationships.map(&:graph_edge)
            end

            def stats
              edge_list = edges

              {
                node_count: nodes.length,
                edge_count: edge_list.length,
                strong_relationships:
                  edge_list.count do |edge|
                    edge[:confidence].to_f >= 0.65
                  end,
                average_confidence:
                  average_confidence(edge_list)
              }
            end

            def average_confidence(edge_list)
              return 0.0 if edge_list.empty?

              (
                edge_list.sum do |edge|
                  edge[:confidence].to_f
                end / edge_list.length
              ).round(4)
            end

          end
        end
      end
    end
  end
end
