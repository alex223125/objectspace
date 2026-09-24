# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class VersioningService

          SNAPSHOT_FIELDS = %w[
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

          def self.create!(
            entity:,
            event_type:,
            metadata: {}
          )
            new(
              entity: entity,
              event_type: event_type,
              metadata: metadata
            ).create!
          end

          def initialize(
            entity:,
            event_type:,
            metadata: {}
          )
            @entity = entity
            @event_type = event_type.to_s
            @metadata = metadata || {}
          end

          def create!
            Entity.transaction do
              version =
                @entity.versions.create!(
                  version_number: next_version_number,
                  snapshot: snapshot
                )

              @entity.update_columns(
                current_version_id: version.id,
                updated_at: Time.current
              )

              @entity.events.create!(
                entity_version_id: version.id,
                event_type: @event_type,
                metadata: @metadata
              )

              version
            end
          end

          private

          def next_version_number
            @entity.versions.maximum(:version_number).to_i + 1
          end

          def snapshot
            SNAPSHOT_FIELDS.each_with_object({}) do |field, result|
              result[field] =
                serialize_value(
                  @entity.public_send(field)
                )
            end
          end

          def serialize_value(value)
            case value
            when ActiveRecord::Base
              value.id
            when Time, DateTime, Date
              value.iso8601
            when Hash
              value.deep_dup
            when Array
              value.map { |item| serialize_value(item) }
            else
              value
            end
          end

        end

      end
    end
  end
end
