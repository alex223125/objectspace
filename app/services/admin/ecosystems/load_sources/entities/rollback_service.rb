# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class RollbackService

          ROLLBACK_FIELDS = %w[
          name
          slug
          entity_type_id
          entity_template_id
          entity_template_version_id
          status
          scope
          summary
          metadata
          valid_from
          valid_until
          observed_at
        ].freeze

          def self.call!(
            entity:,
            version:
          )
            new(
              entity: entity,
              version: version
            ).call!
          end

          def initialize(
            entity:,
            version:
          )
            @entity = entity
            @version = version
          end

          def call!
            validate!

            Entity.transaction do
              apply_snapshot!

              new_version =
                VersioningService.create!(
                  entity: @entity,
                  event_type: EntityEvent::EVENT_TYPES[:rollback],
                  metadata: {
                    "source_version_id" => @version.id,
                    "source_version_number" =>
                      @version.version_number,
                    "rollback_at" =>
                      Time.current.iso8601
                  }
                )

              new_version
            end
          end

          private

          def validate!
            unless @version.entity_id == @entity.id
              raise ArgumentError,
                    "Version does not belong to this entity."
            end
          end

          def apply_snapshot!
            snapshot =
              @version.snapshot_data

            attributes = {}

            ROLLBACK_FIELDS.each do |field|
              next unless snapshot.key?(field)

              attributes[field] =
                restore_value(
                  field,
                  snapshot[field]
                )
            end

            @entity.update!(
              attributes
            )
          end

          def restore_value(field, value)
            case field
            when "valid_from",
              "valid_until",
              "observed_at"

              value.present? ? Time.zone.parse(value.to_s) : nil

            when "metadata"

              value || {}

            else

              value
            end
          end

        end

      end
    end
  end
end
