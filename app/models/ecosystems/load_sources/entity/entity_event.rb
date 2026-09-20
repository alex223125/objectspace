# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EntityEvent < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_events"

        # ==========================================================
        # EVENT TYPES
        # ==========================================================

        CREATED = "created".freeze
        UPDATED = "updated".freeze

        PUBLISHED = "published".freeze
        UNPUBLISHED = "unpublished".freeze

        ARCHIVED = "archived".freeze
        RESTORED = "restored".freeze

        DEPRECATED = "deprecated".freeze

        CLONED = "cloned".freeze

        VERSION_CREATED = "version_created".freeze
        VERSION_RESTORED = "version_restored".freeze

        STATUS_CHANGED = "status_changed".freeze

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
                   polymorphic: true,
                   optional: true

        # ==========================================================
        # VALIDATIONS
        # ==========================================================

        validates :event_type,
                  presence: true

        validates :occurred_at,
                  presence: true

        # ==========================================================
        # IMMUTABILITY
        # ==========================================================

        before_update :prevent_update
        before_destroy :prevent_destroy

        private

        def prevent_update
          throw :abort
        end

        def prevent_destroy
          throw :abort
        end

      end

    end
  end
end