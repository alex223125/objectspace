# frozen_string_literal: true

module Ecosystems
  module LoadSources
    class EntityPolicy
      attr_reader :user, :entity

      def initialize(user, entity)
        @user = user
        @entity = entity
      end

      def submit_for_review?
        authenticated? &&
          can_modify? &&
          entity.can_submit_for_review?
      end

      def assign_reviewer?
        authenticated? &&
          can_modify? &&
          entity.can_assign_reviewer?
      end

      def approve?
        authenticated? &&
          can_modify? &&
          entity.can_approve?
      end

      def reject?
        authenticated? &&
          can_modify? &&
          entity.can_reject?
      end

      def request_changes?
        authenticated? &&
          can_modify? &&
          entity.can_request_changes?
      end

      def comment?
        authenticated? &&
          can_modify?
      end

      def schedule_publish?
        authenticated? &&
          can_modify? &&
          entity.can_schedule_publish?
      end

      def cancel_scheduled_publish?
        authenticated? &&
          can_modify? &&
          entity.can_unschedule_publish?
      end

      def publish?
        authenticated? &&
          can_modify? &&
          entity.can_publish?
      end

      private

      def authenticated?
        user.present?
      end

      def can_modify?
        return false unless user.respond_to?(:has_resource_modify_permissions?)

        user.has_resource_modify_permissions?(entity)
      end
    end
  end
end