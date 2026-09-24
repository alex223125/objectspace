# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities

      class EditorialPermissions

        def initialize(user:, entity:)
          @user = user
          @entity = entity
        end

        def edit?
          role_allowed?(
            :editor,
            :reviewer,
            :admin
          )
        end

        def submit_for_review?
          role_allowed?(
            :editor,
            :admin
          ) &&
            @entity.can_submit_for_review?
        end

        def review?
          role_allowed?(
            :reviewer,
            :admin
          )
        end

        def approve?
          review? &&
            @entity.can_approve?
        end

        def reject?
          review? &&
            @entity.can_reject?
        end

        def request_changes?
          review? &&
            @entity.can_request_changes?
        end

        def assign_reviewer?
          role_allowed?(
            :admin
          )
        end

        def comment?
          role_allowed?(
            :editor,
            :reviewer,
            :admin
          )
        end

        private

        def role_allowed?(*roles)
          roles.any? do |role|
            user_has_role?(role)
          end
        end

        def user_has_role?(role)
          return false unless @user

          if @user.respond_to?(:has_role?)
            @user.has_role?(role)
          elsif @user.respond_to?(:role)
            @user.role.to_s == role.to_s
          elsif @user.respond_to?(:roles)
            @user.roles.any? do |user_role|
              user_role.to_s == role.to_s
            end
          else
            false
          end
        end

      end

    end
  end
end