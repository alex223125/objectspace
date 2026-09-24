# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class EntityLifecycleService

          class LifecycleError < StandardError
          end

          attr_reader :entity, :version, :event

          def initialize(entity)
            @entity = entity
          end

          # ==========================================================
          # PUBLISH
          # ==========================================================

          def publish
            transition!(
              event_type: "published",
              from_status: entity.status.to_s,
              to_status: "published"
            ) do |now|
              {
                published_at: now
              }
            end
          end

          # ==========================================================
          # ARCHIVE
          # ==========================================================

          def archive
            if entity.status.to_s == "archived"
              raise LifecycleError, "Entity is already archived."
            end

            transition!(
              event_type: "archived",
              from_status: entity.status.to_s,
              to_status: "archived"
            ) do |now|
              {
                archived_at: now
              }
            end
          end

          # ==========================================================
          # RESTORE
          # ==========================================================

          def restore
            unless entity.status.to_s == "archived"
              raise LifecycleError, "Entity is not archived."
            end

            transition!(
              event_type: "restored",
              from_status: "archived",
              to_status: "draft"
            ) do |_now|
              {
                archived_at: nil
              }
            end
          end

          private

          # ==========================================================
          # GENERIC LIFECYCLE TRANSITION
          # ==========================================================

          def transition!(event_type:, from_status:, to_status:)
            entity.with_lock do
              now = Time.current

              # Re-check the state after acquiring the row lock.
              #
              # This protects against two simultaneous lifecycle
              # requests operating on the same entity.
              current_status = entity.status.to_s

              unless current_status == from_status
                raise LifecycleError,
                      "Cannot #{event_type} entity from " \
                        "#{current_status}."
              end

              version_number =
                entity.versions
                      .maximum(:version_number)
                      .to_i + 1

              version =
                entity.versions.create!(
                  version_number: version_number,
                  status: to_status,
                  snapshot: entity_version_snapshot(to_status)
                )

              lifecycle_attributes =
                yield(now)

              entity.update!(
                {
                  status: to_status,
                  current_version_id: version.id
                }.merge(lifecycle_attributes)
              )

              event =
                entity.events.create!(
                  entity_version: version,
                  event_type: event_type,
                  from_status: from_status,
                  to_status: to_status,
                  data: {
                    version_number: version.version_number,
                    event_type: event_type,
                    from_status: from_status,
                    to_status: to_status,
                    occurred_at: now.iso8601
                  }
                )

              @version = version
              @event = event
            end

            self
          end

          # ==========================================================
          # VERSION SNAPSHOT
          # ==========================================================

          def entity_version_snapshot(status)
            {
              id: entity.id,

              name: entity.name,
              slug: entity.slug,

              entity_type_id:
                entity.entity_type_id,

              entity_template_id:
                entity.entity_template_id,

              entity_template_version_id:
                entity.entity_template_version_id,

              status: status,

              scope:
                entity.scope.to_s,

              summary:
                entity.summary,

              metadata:
                entity.metadata || {},

              valid_from:
                entity.valid_from&.iso8601,

              valid_until:
                entity.valid_until&.iso8601,

              observed_at:
                entity.observed_at&.iso8601
            }
          end

        end

      end
    end
  end
end


