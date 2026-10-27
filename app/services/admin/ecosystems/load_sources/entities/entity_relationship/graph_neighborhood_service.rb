
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_neighborhood_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphNeighborhoodService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(entity_id:, depth: 1, limit: 100,
                           states: ["confirmed"])
              @entity_id = Integer(entity_id)
              @depth = [[Integer(depth), 1].max, 3].min
              @limit = [[Integer(limit), 1].max, 500].min
              @states = Array(states).map(&:to_s) & %w[
                suggested confirmed rejected archived
              ]
            end

            def call
              return empty_result unless Entity.unscoped.exists?(id: @entity_id)

              ids = [@entity_id]
              frontier = ids.dup
              edges = []

              @depth.times do
                break if frontier.empty? || ids.size >= @limit

                rows = Relationship.unscoped
                                   .where(state: @states)
                                   .where(
                                     "source_entity_id IN (:ids) OR target_entity_id IN (:ids)",
                                     ids: frontier
                                   )
                                   .order(:id)
                                   .limit(5_000)
                                   .to_a

                edges.concat(rows)
                discovered = rows.flat_map do |row|
                  [row.source_entity_id, row.target_entity_id]
                end.compact.uniq

                frontier = (discovered - ids).first(@limit - ids.size)
                ids.concat(frontier)
              end

              entities = Entity.unscoped.where(id: ids).order(:id)
              valid_ids = entities.pluck(:id).to_set

              selected_edges = edges.uniq(&:id).select do |edge|
                valid_ids.include?(edge.source_entity_id) &&
                  valid_ids.include?(edge.target_entity_id)
              end

              {
                root_entity_id: @entity_id,
                depth: @depth,
                nodes: entities.map do |entity|
                  {
                    id: entity.id,
                    name: entity.name.presence || "Entity ##{entity.id}",
                    slug: entity.slug
                  }
                end,
                edges: selected_edges.map do |edge|
                  {
                    id: edge.id,
                    source: edge.source_entity_id,
                    target: edge.target_entity_id,
                    relationship_kind: edge.relationship_kind,
                    state: edge.state,
                    confidence: edge.confidence
                  }
                end,
                truncated: ids.size >= @limit
              }
            end

            private

            def empty_result
              {
                root_entity_id: @entity_id,
                depth: @depth,
                nodes: [],
                edges: [],
                truncated: false
              }
            end
          end
        end
      end
    end
  end
end