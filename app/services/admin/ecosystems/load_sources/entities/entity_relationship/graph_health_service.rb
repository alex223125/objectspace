
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_health_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphHealthService
            Entity = ::Ecosystems::LoadSources::Entity::Entity
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def call
              entity_ids = Entity.unscoped.select(:id)
              relationship_ids = Relationship.unscoped.select(:id)

              total_entities = Entity.unscoped.count
              total_relationships = Relationship.unscoped.count

              missing_source = Relationship.unscoped
                                           .where.not(source_entity_id: entity_ids).count
              missing_target = Relationship.unscoped
                                           .where.not(target_entity_id: entity_ids).count

              self_loops = Relationship.unscoped
                                       .where("source_entity_id = target_entity_id").count

              duplicate_groups = Relationship.unscoped
                                             .group(:source_entity_id, :target_entity_id, :relationship_kind)
                                             .having("COUNT(*) > 1")
                                             .count

              findings = []
              findings << "No entities exist" if total_entities.zero?
              findings << "No relationships exist" if total_relationships.zero?
              findings << "Relationships have missing source entities" if missing_source.positive?
              findings << "Relationships have missing target entities" if missing_target.positive?
              findings << "Self-referential relationships exist" if self_loops.positive?
              findings << "Duplicate relationship groups exist" if duplicate_groups.any?

              {
                status: findings.empty? ? "healthy" : "attention_required",
                entity_count: total_entities,
                relationship_count: total_relationships,
                missing_source_count: missing_source,
                missing_target_count: missing_target,
                self_loop_count: self_loops,
                duplicate_group_count: duplicate_groups.size,
                findings: findings
              }
            end
          end
        end
      end
    end
  end
end