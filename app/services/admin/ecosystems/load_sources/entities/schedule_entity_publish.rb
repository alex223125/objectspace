# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ScheduleEntityPublish

          def self.call!(
            entity:,
            actor:,
            scheduled_publish_at:
          )
            new(
              entity: entity,
              actor: actor,
              scheduled_publish_at: scheduled_publish_at
            ).call!
          end

          def initialize(
            entity:,
            actor:,
            scheduled_publish_at:
          )
            @entity = entity
            @actor = actor
            @scheduled_publish_at = scheduled_publish_at
          end

          def call!
            ActiveRecord::Base.transaction do
              entity.lock!

              validate!

              entity.update!(
                scheduled_publish_at: scheduled_publish_at
              )

              create_event!
            end

            entity
          end

          private

          attr_reader :entity,
                      :actor,
                      :scheduled_publish_at

          def validate!
            unless entity.workflow_state.to_s == "approved"
              raise(
                ArgumentError,
                "Only approved entities can be scheduled."
              )
            end

            if entity.status.to_s == "published"
              raise(
                ArgumentError,
                "Published entities cannot be scheduled."
              )
            end

            unless scheduled_publish_at.present?
              raise(
                ArgumentError,
                "A scheduled publication time is required."
              )
            end

            if scheduled_publish_at <= Time.current
              raise(
                ArgumentError,
                "Scheduled publication must be in the future."
              )
            end
          end

          def create_event!
            ::Ecosystems::LoadSources::Entity::EntityEvent.create!(
              entity: entity,
              event_type: "publish_scheduled",
              actor_id: actor.id,
              occurred_at: Time.current,
              metadata: {
                scheduled_publish_at:
                  scheduled_publish_at.iso8601
              }
            )
          end
        end
      end
    end
  end
end
