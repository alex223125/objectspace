# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities

      class EditorialWorkflow

        class Error < StandardError
        end

        class InvalidState < Error
        end

        class PermissionDenied < Error
        end

        class ValidationError < Error
        end

        class << self

          def submit!(
            entity:,
            actor:,
            comment: nil
          )
            new(
              entity: entity,
              actor: actor
            ).submit!(
              comment: comment
            )
          end

          def assign_reviewer!(
            entity:,
            reviewer:,
            actor:
          )
            new(
              entity: entity,
              actor: actor
            ).assign_reviewer!(
              reviewer: reviewer
            )
          end

          def approve!(
            entity:,
            actor:,
            comment: nil
          )
            new(
              entity: entity,
              actor: actor
            ).approve!(
              comment: comment
            )
          end

          def reject!(
            entity:,
            actor:,
            reason:,
            comment: nil
          )
            new(
              entity: entity,
              actor: actor
            ).reject!(
              reason: reason,
              comment: comment
            )
          end

          def request_changes!(
            entity:,
            actor:,
            reason:,
            comment: nil
          )
            new(
              entity: entity,
              actor: actor
            ).request_changes!(
              reason: reason,
              comment: comment
            )
          end

          def comment!(
            entity:,
            actor:,
            body:
          )
            new(
              entity: entity,
              actor: actor
            ).comment!(
              body: body
            )
          end

        end

        attr_reader :entity, :actor

        def initialize(entity:, actor:)
          @entity = entity
          @actor = actor
        end

        # ==========================================================
        # SUBMIT FOR REVIEW
        # ==========================================================

        def submit!(comment: nil)
          ensure_actor!

          unless entity.can_submit_for_review?
            raise InvalidState,
                  "Entity cannot currently be submitted for review."
          end

          unless entity.complete?
            raise ValidationError,
                  "Entity cannot be submitted because it has " \
                    "quality issues: #{entity.quality_issues.to_sentence}"
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            entity.update!(
              workflow_state: "review",
              submitted_for_review_at: Time.current,
              submitted_by_id: actor_id,
              rejected_at: nil,
              rejected_by_id: nil,
              rejection_reason: nil
            )

            record_event!(
              :submitted_for_review,
              metadata: {
                comment: comment.to_s.presence
              }
            )

            entity
          end
        end

        # ==========================================================
        # ASSIGN REVIEWER
        # ==========================================================

        def assign_reviewer!(reviewer:)
          ensure_actor!
          ensure_reviewer!(reviewer)

          unless entity.workflow_state_review?
            raise InvalidState,
                  "A reviewer can only be assigned while the entity " \
                    "is in review."
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            entity.update!(
              reviewer_id: reviewer.id,
              reviewer_assigned_at: Time.current,
              reviewer_assigned_by_id: actor_id
            )

            record_event!(
              :reviewer_assigned,
              metadata: {
                reviewer_id: reviewer.id,
                reviewer_name: reviewer.respond_to?(:name) ? reviewer.name : nil
              }
            )

            entity
          end
        end

        # ==========================================================
        # APPROVE
        # ==========================================================

        def approve!(comment: nil)
          ensure_actor!

          unless entity.can_approve?
            raise InvalidState,
                  "Only entities in review can be approved."
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            entity.update!(
              workflow_state: "approved",
              approved_at: Time.current,
              approved_by_id: actor_id,
              review_comment:
                comment.to_s.presence || entity.review_comment
            )

            record_event!(
              :approved,
              metadata: {
                comment: comment.to_s.presence
              }
            )

            entity
          end
        end

        # ==========================================================
        # REJECT
        # ==========================================================

        def reject!(reason:, comment: nil)
          ensure_actor!

          reason =
            reason.to_s.strip

          if reason.blank?
            raise ValidationError,
                  "A rejection reason is required."
          end

          unless entity.can_reject?
            raise InvalidState,
                  "Only entities in review can be rejected."
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            entity.update!(
              workflow_state: "rejected",
              rejected_at: Time.current,
              rejected_by_id: actor_id,
              rejection_reason: reason,
              review_comment: comment.to_s.presence
            )

            record_event!(
              :rejected,
              metadata: {
                rejection_reason: reason,
                comment: comment.to_s.presence
              }
            )

            entity
          end
        end

        # ==========================================================
        # REQUEST CHANGES
        # ==========================================================

        def request_changes!(reason:, comment: nil)
          ensure_actor!

          reason =
            reason.to_s.strip

          if reason.blank?
            raise ValidationError,
                  "A change request reason is required."
          end

          unless entity.workflow_state_review?
            raise InvalidState,
                  "Changes can only be requested while the entity " \
                    "is in review."
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            entity.update!(
              workflow_state: "rejected",
              rejected_at: Time.current,
              rejected_by_id: actor_id,
              rejection_reason: reason,
              review_comment: comment.to_s.presence
            )

            record_event!(
              :change_requested,
              metadata: {
                reason: reason,
                comment: comment.to_s.presence
              }
            )

            entity
          end
        end

        # ==========================================================
        # COMMENT
        # ==========================================================

        def comment!(body:)
          ensure_actor!

          body =
            body.to_s.strip

          if body.blank?
            raise ValidationError,
                  "Comment cannot be blank."
          end

          ActiveRecord::Base.transaction do
            entity.lock!

            record_event!(
              :comment_added,
              metadata: {
                body: body
              }
            )

            entity
          end
        end

        private

        # ==========================================================
        # ACTOR
        # ==========================================================

        def ensure_actor!
          return if actor.present?

          raise PermissionDenied,
                "An authenticated user is required."
        end

        def actor_id
          actor.respond_to?(:id) ? actor.id : actor
        end

        # ==========================================================
        # REVIEWER
        # ==========================================================

        def ensure_reviewer!(reviewer)
          unless reviewer.respond_to?(:id) &&
            reviewer.id.present?
            raise ValidationError,
                  "A valid reviewer is required."
          end
        end

        # ==========================================================
        # EVENTS
        # ==========================================================

        def record_event!(event_type, metadata: {})
          ::Ecosystems::LoadSources::Entity::EntityEvent.record!(
            entity: entity,
            entity_version: entity.current_version,
            event_type: event_type,
            actor: actor,
            metadata: metadata
          )
        end

      end

    end
  end
end