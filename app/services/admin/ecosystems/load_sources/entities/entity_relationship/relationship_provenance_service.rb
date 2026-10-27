
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/relationship_provenance_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipProvenanceService
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            AuditEvent =
              ::Ecosystems::LoadSources::Entity::RelationshipAuditEvent

            def initialize(relationship_id:)
              @relationship_id = Integer(relationship_id)
            end

            def call
              relationship = Relationship.unscoped.find(@relationship_id)

              {
                relationship: {
                  id: relationship.id,
                  source_entity_id: relationship.source_entity_id,
                  target_entity_id: relationship.target_entity_id,
                  relationship_kind: relationship.relationship_kind,
                  state: relationship.state,
                  confidence: relationship.confidence,
                  evidence: relationship.evidence,
                  last_discovered_at: relationship.last_discovered_at,
                  created_at: relationship.created_at,
                  updated_at: relationship.updated_at
                },
                audit_events: AuditEvent
                                .where(relationship_id: relationship.id)
                                .order(created_at: :desc)
                                .limit(100)
                                .map do |event|
                  {
                    action: event.action,
                    actor_id: event.actor_id,
                    before_state: event.before_state,
                    after_state: event.after_state,
                    details: event.details,
                    occurred_at: event.created_at
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