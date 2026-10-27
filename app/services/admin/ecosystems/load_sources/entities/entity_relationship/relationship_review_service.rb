
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/relationship_review_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipReviewService
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            AuditEvent =
              ::Ecosystems::LoadSources::Entity::RelationshipAuditEvent

            def initialize(relationship_id:, actor:, action:, comment: nil)
              @relationship_id = Integer(relationship_id)
              @actor = actor
              @action = action.to_s
              @comment = comment.to_s.strip.first(2_000)
            end

            def call
              raise ArgumentError, "Invalid review action" unless
                %w[confirm reject].include?(@action)

              raise ArgumentError, "Reviewer is required" unless @actor

              Relationship.transaction do
                relationship = Relationship.unscoped
                                           .lock.find(@relationship_id)

                unless relationship.state == "suggested"
                  raise ArgumentError,
                        "Only suggested relationships can be reviewed"
                end

                previous_state = relationship.state
                new_state = @action == "confirm" ? "confirmed" : "rejected"

                relationship.update!(state: new_state)

                AuditEvent.create!(
                  relationship_id: relationship.id,
                  source_entity_id: relationship.source_entity_id,
                  target_entity_id: relationship.target_entity_id,
                  actor_id: @actor.id,
                  action: @action,
                  before_state: previous_state,
                  after_state: new_state,
                  details: { comment: @comment }
                )

                relationship
              end
            end
          end
        end
      end
    end
  end
end