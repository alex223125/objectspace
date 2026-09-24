# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class InvalidateApproval

          def self.call!(
            entity:,
            actor:,
            reason:
          )
            new(
              entity: entity,
              actor: actor,
              reason: reason
            ).call!
          end

          def initialize(
            entity:,
            actor:,
            reason:
          )
            @entity = entity
            @actor = actor
            @reason = reason
          end

          def call!
            ActiveRecord::Base.transaction do
              entity.lock!

              return entity unless invalidation_required?

              previous_state =
                entity.workflow_state.to_s

              previous_publish_at =
                entity.publish_at

              entity.update!(
                workflow_state: "review",
                publish_at: nil,
                submitted_for_review_at: nil,
                approved_at: nil,
                approved_by_id: nil,
                rejected_at: nil,
                rejected_by_id: nil
              )

              create_event!(
                previous_state: previous_state,
                previous_publish_at: previous_publish_at
              )
            end

            entity
          end

          private

          attr_reader :entity,
                      :actor,
                      :reason

          def invalidation_required?
            entity.workflow_state.to_s == "approved" ||
              entity.publish_at.present?
          end

          def create_event!(
            previous_state:,
            previous_publish_at:
          )
            ::Ecosystems::LoadSources::Entity::EntityEvent.create!(
              entity: entity,
              event_type: "approval_invalidated",
              actor_id: actor_id,
              occurred_at: Time.current,
              metadata: {
                reason: reason,
                previous_workflow_state:
                  previous_state,
                previous_publish_at:
                  previous_publish_at&.iso8601
              }.compact
            )
          end

          def actor_id
            return nil unless actor

            actor.id
          end

        end
      end
    end
  end
end