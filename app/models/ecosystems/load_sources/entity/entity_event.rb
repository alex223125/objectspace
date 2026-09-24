# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EntityEvent < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_events"

        TYPES = {
          created: "created",
          updated: "updated",

          submitted_for_review:
            "submitted_for_review",

          reviewer_assigned:
            "reviewer_assigned",

          comment_added:
            "comment_added",

          approved:
            "approved",

          rejected:
            "rejected",

          change_requested:
            "change_requested",

          approval_invalidated:
            "approval_invalidated",

          publish_scheduled:
            "publish_scheduled",

          publish_schedule_cancelled:
            "publish_schedule_cancelled",

          published:
            "published",

          archived:
            "archived",

          restored:
            "restored",

          deprecated:
            "deprecated",

          cloned:
            "cloned",

          rollback:
            "rollback"
        }.freeze

        # ==========================================================
        # ASSOCIATIONS
        # ==========================================================

        belongs_to :entity,
                   class_name:
                     "Ecosystems::LoadSources::Entity::Entity"

        belongs_to :entity_version,
                   class_name:
                     "Ecosystems::LoadSources::Entity::EntityVersion",
                   optional: true

        belongs_to :actor,
                   class_name: "User",
                   foreign_key: :actor_id,
                   optional: true

        # ==========================================================
        # VALIDATIONS
        # ==========================================================

        validates :event_type,
                  presence: true,
                  inclusion: {
                    in: TYPES.values
                  }

        validates :metadata,
                  presence: true

        validates :occurred_at,
                  presence: true

        # ==========================================================
        # IMMUTABILITY
        # ==========================================================

        before_update :prevent_modification
        before_destroy :prevent_destruction

        # ==========================================================
        # SCOPES
        # ==========================================================

        scope :chronological,
              -> {
                order(created_at: :asc)
              }

        scope :recent_first,
              -> {
                order(created_at: :desc)
              }

        # ==========================================================
        # EVENT CREATION
        # ==========================================================

        def self.type_for(name)
          TYPES.fetch(name.to_sym)
        end

        def self.record!(
          entity:,
          event_type:,
          entity_version: nil,
          actor: nil,
          metadata: {},
          from_status: nil,
          to_status: nil,
          message: nil,
          snapshot: {}
        )
          create!(
            entity: entity,
            entity_version: entity_version,

            event_type:
              type_for(event_type),

            from_status:
              from_status,

            to_status:
              to_status,

            actor_type:
              actor_type_for(actor),

            actor_id:
              actor_id_for(actor),

            message:
              message,

            metadata:
              metadata || {},

            snapshot:
              snapshot || {},

            created_at:
              Time.current
          )
        end

        # ==========================================================
        # ACTOR
        # ==========================================================

        def self.actor_id_for(actor)
          return nil unless actor

          if actor.respond_to?(:id)
            actor.id
          elsif actor.is_a?(Integer)
            actor
          else
            nil
          end
        end

        def self.actor_type_for(actor)
          return nil unless actor

          if actor.respond_to?(:id)
            actor.class.name
          else
            "User"
          end
        end

        # ==========================================================
        # HELPERS
        # ==========================================================

        def self.type_for_name(name)
          type_for(name)
        end

        def chronological?
          true
        end

        # ==========================================================
        # IMMUTABILITY
        # ==========================================================

        private

        def prevent_modification
          raise ActiveRecord::ReadOnlyRecord,
                "Entity events are immutable and cannot be modified"
        end

        def prevent_destruction
          raise ActiveRecord::ReadOnlyRecord,
                "Entity events are immutable and cannot be destroyed"
        end

      end

    end
  end
end