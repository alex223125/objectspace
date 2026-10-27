
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_diagnostics_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphDiagnosticsService
            def initialize(entity_limit: 500)
              @entity_limit = [[entity_limit.to_i, 1].max, 10_000].min
            end

            def call
              entity_model = ::Ecosystems::LoadSources::Entity::Entity
              relationship_model =
                ::Ecosystems::LoadSources::Entity::EntityRelationship

              entities = entity_model.unscoped
                                     .order(:id)
                                     .limit(@entity_limit)

              entity_ids = entities.pluck(:id)

              relationships = relationship_model.unscoped
              valid = relationships.where(
                source_entity_id: entity_ids
              ).or(
                relationships.where(target_entity_id: entity_ids)
              )

              endpoint_ids = valid.pluck(
                :source_entity_id, :target_entity_id
              ).flatten.compact.uniq

              confirmed = valid.where(state: "confirmed")
              suggested = valid.where(state: "suggested")
              rejected = valid.where(state: "rejected")
              archived = valid.where(state: "archived")

              {
                entity_count: entity_ids.size,
                relationship_count: valid.count,
                confirmed_relationship_count: confirmed.count,
                suggested_relationship_count: suggested.count,
                rejected_relationship_count: rejected.count,
                archived_relationship_count: archived.count,
                isolated_entity_count: entity_ids.count do |id|
                  !endpoint_ids.include?(id)
                end,
                missing_source_count: relationships
                                        .where.not(source_entity_id: entity_ids)
                                        .where(target_entity_id: entity_ids).count,
                missing_target_count: relationships
                                        .where(source_entity_id: entity_ids)
                                        .where.not(target_entity_id: entity_ids).count,
                sampled: entity_ids.size >= @entity_limit
              }
            end
          end
        end
      end
    end
  end
end