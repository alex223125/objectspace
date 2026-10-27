# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EntityDossierService
          def initialize(entity_id:, relationship_limit: 100)
            @entity_id = Integer(entity_id, 10) rescue nil
            @relationship_limit = [[relationship_limit.to_i, 1].max, 300].min
          end

          def call
            return failure("Invalid entity ID.") unless @entity_id&.positive?

            entity = entity_model.unscoped.find_by(id: @entity_id)
            return failure("Entity not found.") unless entity

            outgoing = relationship_model.unscoped
                                         .where(source_entity_id: entity.id)
                                         .order(updated_at: :desc)
                                         .limit(@relationship_limit)
                                         .to_a

            incoming = relationship_model.unscoped
                                         .where(target_entity_id: entity.id)
                                         .order(updated_at: :desc)
                                         .limit(@relationship_limit)
                                         .to_a

            endpoint_ids = (outgoing + incoming)
                             .flat_map { |edge| [edge.source_entity_id, edge.target_entity_id] }
                             .compact
                             .uniq

            names = entity_model.unscoped
                                .where(id: endpoint_ids)
                                .pluck(:id, :name)
                                .to_h

            {
              success: true,
              entity: {
                id: entity.id,
                name: entity.name,
                slug: entity.slug,
                summary: entity.summary,
                status: entity.status,
                scope: entity.scope,
                workflow_state: entity.workflow_state,
                entity_type_id: entity.entity_type_id,
                entity_template_id: entity.entity_template_id,
                created_at: entity.created_at,
                updated_at: entity.updated_at,
                published_at: entity.published_at,
                metadata: safe_metadata(entity.metadata)
              },
              relationships: {
                outgoing: outgoing.map { |edge| serialize_edge(edge, names) },
                incoming: incoming.map { |edge| serialize_edge(edge, names) },
                outgoing_count: outgoing.size,
                incoming_count: incoming.size
              },
              generated_at: Time.current.iso8601
            }
          end

          private

          def serialize_edge(edge, names)
            {
              id: edge.id,
              source_entity_id: edge.source_entity_id,
              source_name: names[edge.source_entity_id],
              target_entity_id: edge.target_entity_id,
              target_name: names[edge.target_entity_id],
              relationship_kind: edge.relationship_kind,
              state: edge.state,
              confidence: edge.confidence,
              evidence: edge.evidence,
              last_discovered_at: edge.last_discovered_at,
              updated_at: edge.updated_at
            }
          end

          def safe_metadata(value)
            return {} unless value.is_a?(Hash)

            value.to_a.first(100).to_h
          end

          def failure(message)
            { success: false, error: message }
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