# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class ChangeRequest < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_change_requests"

        STATUSES = {
          open: "open",
          resolved: "resolved",
          cancelled: "cancelled"
        }.freeze

        belongs_to :entity,
                   class_name:
                     "Ecosystems::LoadSources::Entity::Entity"

        belongs_to :entity_version,
                   class_name:
                     "Ecosystems::LoadSources::Entity::EntityVersion",
                   optional: true

        belongs_to :requested_by,
                   class_name: "User"

        belongs_to :assigned_to,
                   class_name: "User",
                   optional: true

        belongs_to :resolved_by,
                   class_name: "User",
                   optional: true

        validates :reason,
                  presence: true

        validates :status,
                  presence: true,
                  inclusion: {
                    in: STATUSES.values
                  }

        scope :open, -> {
          where(status: STATUSES[:open])
        }

        scope :resolved, -> {
          where(status: STATUSES[:resolved])
        }

        scope :cancelled, -> {
          where(status: STATUSES[:cancelled])
        }

        def open?
          status == STATUSES[:open]
        end

        def resolved?
          status == STATUSES[:resolved]
        end

        def cancelled?
          status == STATUSES[:cancelled]
        end

        def resolve!(user:)
          update!(
            status: STATUSES[:resolved],
            resolved_at: Time.current,
            resolved_by: user
          )
        end

        def cancel!(user:)
          update!(
            status: STATUSES[:cancelled],
            resolved_at: Time.current,
            resolved_by: user
          )
        end

      end

    end
  end
end