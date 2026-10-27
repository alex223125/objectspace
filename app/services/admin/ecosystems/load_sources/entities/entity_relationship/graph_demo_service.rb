
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_demo_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphDemoService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(limit: 50)
              @limit = [[limit.to_i, 1].max, 200].min
            end

            def call
              edges = Relationship.unscoped
                                  .where(state: "confirmed")
                                  .order(id: :desc)
                                  .limit(@limit * 3)
                                  .to_a

              ids = edges.flat_map do |edge|
                [edge.source_entity_id, edge.target_entity_id]
              end.compact.uniq.first(@limit)

              entities = Entity.unscoped.where(id: ids).index_by(&:id)
              edges.select! do |edge|
                entities.key?(edge.source_entity_id) &&
                  entities.key?(edge.target_entity_id)
              end

              {
                presentation_mode: true,
                demo_data: false,
                data_notice: "Live database records; no synthetic evidence added.",
                nodes: entities.values.map do |entity|
                  {
                    id: entity.id,
                    name: entity.name.presence || "Entity ##{entity.id}",
                    summary: entity.summary
                  }
                end,
                edges: edges.map do |edge|
                  {
                    id: edge.id,
                    source: edge.source_entity_id,
                    target: edge.target_entity_id,
                    kind: edge.relationship_kind,
                    confidence: edge.confidence
                  }
                end
              }
            end
          end
        end
      end
    end
  end
end