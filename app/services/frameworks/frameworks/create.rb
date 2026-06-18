require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/shared/owner_permissionable"

module Services
  module Frameworks
    module Frameworks
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include Services::Concerns::Shared::OwnerPermissionable

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :framework, :permission

        def initialize(params, target_place, owner, creator)
          @params = params
          @target_place = target_place
          @owner = owner
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            create_framework
            # link_framework_with_all_containers
            # link_framework_with_all_interface_groups

            binding.pry
            set_owner
            set_creator

            binding.pry
            set_place
            set_tags

            binding.pry
            @framework.save!

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def technology
          @framework
        end

        def entity
          @framework
        end

        def create_framework
          binding.pry
          @framework = ::Frameworks::Framework.new(@params.except(:tag_list))
        end

        # def link_framework_with_all_containers
        #   binding.pry
        #   service = Services::Shared::LinkGroupsWithObject.new(@framework,
        #                                                        CLASS_CONTAINER_ROOT_ASSOCIATION,
        #                                                        CLASS_CONTAINER_CHILD_ASSOCIATIONS)
        #   service.call
        # end
        #
        # def link_framework_with_all_interface_groups
        #   binding.pry
        #   service = Services::Shared::LinkGroupsWithObject.new(@framework,
        #                                                        INTERFACE_GROUP_ROOT_ASSOCIATION,
        #                                                        INTERFACE_GROUP_CHILD_ASSOCIATIONS)
        #   service.call
        # end

        def set_owner
          binding.pry
          @framework.ownerable = @owner
        end

        def set_creator
          @framework.creator = @creator
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @framework.folder = @target_place
          elsif @target_place.class == Repository
            @framework.repository = @target_place
          end
        end

      end
    end
  end
end
