
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class AuditService
            ACTIONS = %w[
              review_started
              review_completed
              decision_recorded
              annotation_created
              assignment_changed
              export_created
              comparison_opened
            ].freeze

            def initialize(actor:, action:, target:, metadata: {})
              @actor = actor
              @action = action.to_s
              @target = target
              @metadata = metadata.is_a?(Hash) ? metadata : {}
            end

            def call
              errors = []
              errors << "actor_required" if actor.blank?
              errors << "invalid_action" unless ACTIONS.include?(action)
              errors << "target_required" if target.blank?

              {
                valid: errors.empty?,
                errors: errors,
                event: {
                  actor_id: actor.respond_to?(:id) ? actor.id : actor,
                  action: action,
                  target_type: target.class.name,
                  target_id: target.respond_to?(:id) ? target.id : target,
                  metadata: metadata,
                  occurred_at: Time.current.iso8601
                }
              }
            end

            private

            attr_reader :actor, :action, :target, :metadata
          end
        end
      end
    end
  end
end