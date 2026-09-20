# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EntityVersion < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_versions"

        # ==========================================================
        # ASSOCIATIONS
        # ==========================================================

        belongs_to :entity,
                   class_name:
                     "Ecosystems::LoadSources::Entity::Entity"

        belongs_to :created_by,
                   polymorphic: true,
                   optional: true

        has_many :events,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEvent",
                 foreign_key: :entity_version_id,
                 dependent: :nullify

        # ==========================================================
        # VALIDATIONS
        # ==========================================================

        validates :version_number,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than: 0
                  }

        validates :status,
                  presence: true

        validates :snapshot,
                  presence: true

        validates :version_number,
                  uniqueness: {
                    scope: :entity_id
                  }

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