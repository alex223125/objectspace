# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class CancelEntityPublish

          def self.call!(
            entity:,
            actor:,
            reason: nil
          )
            new(
              entity: entity,
              actor: actor,
              reason: reason
            ).call!
          end

          def initialize(entity:, actor:, reason:)
            @entity = entity
            @actor = actor
            @reason = reason
          end

          def call!
            ActiveRecord::Base.transaction do
              entity.lock!

              validate!

              previous_time =
                entity.scheduled_publish_at

              entity.update!(
                scheduled_publish_at: nil
              )

              ::Ecosystems::LoadSources::Entity::EntityEvent.create!(
                entity: entity,
                event_type: "publish_schedule_cancelled",
                actor_id: actor.id,
                occurred_at: Time.current,
                metadata: {
                  previous_scheduled_publish_at:
                    previous_time&.iso8601,
                  reason: reason
                }.compact
              )
            end

            entity
          end

          private

          attr_reader :entity,
                      :actor,
                      :reason

          def validate!
            unless entity.scheduled_publish_at.present?
              raise(
                ArgumentError,
                "Entity has no scheduled publication."
              )
            end

            unless entity.workflow_state.to_s == "approved"
              raise(
                ArgumentError,
                "Only approved entities can have a scheduled publication."
              )
            end
          end
        end
      end
    end
  end
end
