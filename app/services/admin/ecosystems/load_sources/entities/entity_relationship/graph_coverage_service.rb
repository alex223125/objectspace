# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphCoverageService
            def call
              total_entities = entity_model.unscoped.count
              total_relationships = relationship_model.unscoped.count

              connected_ids = relationship_model.unscoped
                                                .pluck(:source_entity_id, :target_entity_id)
                                                .flatten.compact.uniq

              connected_count = connected_ids.size
              isolated_count = [total_entities - connected_count, 0].max

              {
                total_entities: total_entities,
                connected_entities: connected_count,
                isolated_entities: isolated_count,
                connected_entity_percent: percentage(connected_count, total_entities),
                isolated_entity_percent: percentage(isolated_count, total_entities),
                total_relationships: total_relationships,
                coverage_definition: "An entity is connected when its ID occurs as either endpoint of at least one stored relationship."
              }
            end

            private

            def percentage(part, whole)
              whole.zero? ? 0.0 : (part.to_f / whole * 100).round(1)
            end

            def entity_model
              ::Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_model
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            end
          end
        end
      end
    end
  end
end