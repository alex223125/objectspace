module Services
  module Permissions
    module ResourceOwner
      class Create

        attr_reader :permission

        def initialize(permissionable, actorable)
          @permissionable = permissionable
          @actorable = actorable
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_permission
            set_target
            set_actor
            set_allowed_actions
            set_source_type

            binding.pry
            @permission.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_permission
          @permission = Permission.new
        end

        def set_target
          @permission.permissionable = @permissionable
        end

        def set_actor
          @permission.actorable = @actorable
        end

        def set_allowed_actions
          @permission.allowed_action_type = ::Permissions::AllowedActionTypes[:all_actions]
        end

        def set_source_type
          @permission.source_type = ::Permissions::SourceTypes[:created_automatically]
        end
      end
    end
  end
end

