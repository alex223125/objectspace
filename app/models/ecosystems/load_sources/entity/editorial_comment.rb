# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EditorialComment < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_editorial_comments"

        belongs_to :entity,
                   class_name:
                     "Ecosystems::LoadSources::Entity::Entity"

        belongs_to :entity_version,
                   class_name:
                     "Ecosystems::LoadSources::Entity::EntityVersion",
                   optional: true

        belongs_to :user,
                   class_name: "User"

        belongs_to :resolved_by,
                   class_name: "User",
                   optional: true

        validates :body, presence: true

        scope :open, -> {
          where(resolved_at: nil)
        }

        scope :resolved, -> {
          where.not(resolved_at: nil)
        }

        def open?
          resolved_at.nil?
        end

        def resolved?
          resolved_at.present?
        end

        def resolve!(user:)
          update!(
            resolved_at: Time.current,
            resolved_by: user
          )
        end

      end

    end
  end
end