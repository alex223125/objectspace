module Services
  module Concerns
    module Shared
      module OwnerPermissionable
        extend ActiveSupport::Concern

        def create_resource_owner_permission
          service = Services::Permissions::ResourceOwner::Create.new(entity, @owner)
          service.call
          if service.permission.errors.present?
            binding.pry
            @permission = service.permission
            raise ActiveRecord::RecordInvalid.new(@permission)
          end
        end

      end
    end
  end
end