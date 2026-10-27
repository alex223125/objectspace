
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/entity_relationship/graph_change_feed_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphChangeFeedService
            MAX_LIMIT = 200
            DEFAULT_LIMIT = 50

            def initialize(limit: DEFAULT_LIMIT, since: nil)
              @limit = [[limit.to_i, 1].max, MAX_LIMIT].min
              @since = since
            end

            def call
              events = audit_event_model.all
              events = events.where("created_at >= ?", parse_since) if since?

              {
                source: "relationship_audit_events",
                changes: events
                           .order(created_at: :desc, id: :desc)
                           .limit(@limit)
                           .map do |event|
                  {
                    id: event.id,
                    relationship_id: event.relationship_id,
                    action: event.action,
                    actor_id: event.actor_id,
                    before_state: event.before_state,
                    after_state: event.after_state,
                    created_at: event.created_at
                  }
                end
              }
            end

            private

            def audit_event_model
              ::Ecosystems::LoadSources::Entity::RelationshipAuditEvent
            end

            # Kept available for callers that need the relationship model.
            def relationship_model
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            end

            def since?
              @since.present?
            end

            def parse_since
              parsed = Time.zone.parse(@since.to_s)
              return parsed if parsed

              raise ArgumentError, "Invalid since timestamp"
            rescue TypeError, ArgumentError => e
              raise e if e.message == "Invalid since timestamp"

              raise ArgumentError, "Invalid since timestamp"
            end
          end
        end
      end
    end
  end
end