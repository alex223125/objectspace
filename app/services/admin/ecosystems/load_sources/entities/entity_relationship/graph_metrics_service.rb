
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_metrics_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphMetricsService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize
              @entities = Entity.unscoped
              @relationships = Relationship.unscoped
            end

            def call
              total_entities = @entities.count
              total_relationships = @relationships.count

              confirmed = @relationships.where(state: "confirmed").count
              suggested = @relationships.where(state: "suggested").count

              endpoint_ids = @relationships
                               .pluck(:source_entity_id, :target_entity_id)
                               .flatten.compact.uniq

              {
                entity_count: total_entities,
                relationship_count: total_relationships,
                confirmed_relationship_count: confirmed,
                suggested_relationship_count: suggested,
                isolated_entity_count: [total_entities - endpoint_ids.size, 0].max,
                average_degree: average_degree(total_entities, total_relationships),
                confirmation_rate: percentage(confirmed, total_relationships),
                relationship_states: @relationships.group(:state).count,
                relationship_kinds: @relationships
                                      .group(:relationship_kind).count
              }
            end

            private

            def average_degree(nodes, edges)
              return 0.0 if nodes.zero?

              (2.0 * edges / nodes).round(3)
            end

            def percentage(part, total)
              return 0.0 if total.zero?

              (100.0 * part / total).round(2)
            end
          end
        end
      end
    end
  end
end