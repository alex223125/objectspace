
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/relationship_audit_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipAuditService
            AuditEvent =
              ::Ecosystems::LoadSources::Entity::RelationshipAuditEvent

            def initialize(relationship_id: nil, limit: 100)
              @relationship_id = relationship_id
              @limit = [[limit.to_i, 1].max, 500].min
            end

            def call
              scope = AuditEvent.all
              scope = scope.where(relationship_id: @relationship_id) if
                @relationship_id.present?

              scope.order(created_at: :desc, id: :desc)
                   .limit(@limit)
                   .map do |event|
                {
                  id: event.id,
                  relationship_id: event.relationship_id,
                  source_entity_id: event.source_entity_id,
                  target_entity_id: event.target_entity_id,
                  actor_id: event.actor_id,
                  action: event.action,
                  before_state: event.before_state,
                  after_state: event.after_state,
                  details: event.details,
                  created_at: event.created_at
                }
              end
            end
          end
        end
      end
    end
  end
end