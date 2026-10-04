# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class RelationshipGraphService

        DEFAULT_LIMIT = 100
        DEFAULT_DEPTH = 1

        def initialize(
          entity_ids: nil,
          root_entity_id: nil,
          limit: DEFAULT_LIMIT,
          depth: DEFAULT_DEPTH
        )
          @entity_ids = Array(entity_ids).compact.map(&:to_i).uniq
          @root_entity_id = root_entity_id&.to_i
          @limit = limit.to_i.clamp(1, 500)
          @depth = depth.to_i.clamp(1, 3)
        end

        def call
          entities = load_entities
          relationships = load_relationships(entities)

          {
            nodes: build_nodes(entities),
            edges: build_edges(relationships),
            meta: {
              node_count: entities.length,
              edge_count: relationships.length,
              root_entity_id: @root_entity_id,
              depth: @depth
            }
          }
        end

        private

        def entity_model
          Ecosystems::LoadSources::Entity::Entity
        end

        def relationship_model
          Ecosystems::LoadSources::Entity::EntityRelationship
        end

        def load_entities
          if @root_entity_id.present?
            load_from_root
          elsif @entity_ids.any?
            entity_model
              .where(id: @entity_ids)
              .includes(:entity_type, :entity_template)
              .limit(@limit)
              .to_a
          else
            entity_model
              .where(id: [])
              .to_a
          end
        end

        def load_from_root
          root =
            entity_model
              .includes(:entity_type, :entity_template)
              .find(@root_entity_id)

          discovered_ids = [root.id]

          frontier = [root.id]

          @depth.times do
            next_frontier = []

            relationship_model
              .active
              .where(
                "source_entity_id IN (:ids) OR target_entity_id IN (:ids)",
                ids: frontier
              )
              .limit(@limit * 2)
              .find_each do |relationship|

              other_id =
                if frontier.include?(relationship.source_entity_id)
                  relationship.target_entity_id
                else
                  relationship.source_entity_id
                end

              next if discovered_ids.include?(other_id)

              discovered_ids << other_id
              next_frontier << other_id

              break if discovered_ids.length >= @limit
            end

            frontier = next_frontier

            break if frontier.empty?
            break if discovered_ids.length >= @limit
          end

          entity_model
            .where(id: discovered_ids.first(@limit))
            .includes(:entity_type, :entity_template)
            .to_a
        end

        def load_relationships(entities)
          ids = entities.map(&:id)

          return [] if ids.empty?

          relationship_model
            .active
            .where(
              source_entity_id: ids,
              target_entity_id: ids
            )
            .includes(:source_entity, :target_entity)
            .order(confidence: :desc)
            .limit(@limit * 3)
            .to_a
        end

        def build_nodes(entities)
          entities.map do |entity|
            {
              id: entity.id,
              label: entity.name,
              slug: entity.slug,
              type: entity.entity_type&.name,
              template: entity.entity_template&.name,
              scope: entity.scope,
              status: entity.status,
              health_score:
                entity.respond_to?(:health_score) ?
                  entity.health_score :
                  nil,
              relationship_count:
                entity.respond_to?(:relationship_count) ?
                  entity.relationship_count :
                  0
            }
          end
        end

        def build_edges(relationships)
          relationships.map(&:graph_payload)
        end

      end

    end
  end
end