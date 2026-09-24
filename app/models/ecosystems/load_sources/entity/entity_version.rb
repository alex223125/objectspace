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

        has_many :events,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEvent",
                 foreign_key: :entity_version_id,
                 dependent: :restrict_with_exception




        # ==========================================================
        # VALIDATIONS
        # ==========================================================

        validates :version_number,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than: 0
                  }

        validates :snapshot,
                  presence: true

        validates :version_number,
                  uniqueness: {
                    scope: :entity_id
                  }

        # ==========================================================
        # IMMUTABILITY
        # ==========================================================

        before_update :prevent_modification
        before_destroy :prevent_destruction

        # ==========================================================
        # SNAPSHOT
        # ==========================================================

        def snapshot
          value = self[:snapshot]

          case value
          when Hash
            value
          when ActionController::Parameters
            value.to_h
          else
            {}
          end
        end

        # ==========================================================
        # SNAPSHOT HELPERS
        # ==========================================================

        def snapshot
          self[:snapshot] || {}
        end

        def snapshot?
          snapshot.present?
        end

        def snapshot_value(path)
          return snapshot if path.blank?

          path
            .to_s
            .split(".")
            .reduce(snapshot) do |value, key|
            break nil unless value.respond_to?(:[])

            value[key] ||
              value[key.to_sym]
          end
        end


        # ==========================================================
        # DISPLAY HELPERS
        # ==========================================================

        def label
          "Version #{version_number}"
        end

        def published?
          published_at.present?
        end

        # ==========================================================
        # IMMUTABILITY
        # ==========================================================

        private

        def prevent_modification
          throw :abort
        end

        def prevent_destruction
          throw :abort
        end

      end

    end
  end
end