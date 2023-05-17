module Services
  module Frameworks
    module Frameworks
      class Create

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :framework

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            create_framework
            link_framework_with_all_containers
            link_framework_with_all_interface_groups
            binding.pry
            @framework.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_framework
          binding.pry
          @framework = ::Frameworks::Framework.new(@params)
        end

        def link_framework_with_all_containers
          binding.pry
          service = Services::Shared::LinkGroupsWithObject.new(@framework,
                                                               CLASS_CONTAINER_ROOT_ASSOCIATION,
                                                               CLASS_CONTAINER_CHILD_ASSOCIATIONS)
          service.call
        end

        def link_framework_with_all_interface_groups
          binding.pry
          service = Services::Shared::LinkGroupsWithObject.new(@framework,
                                                               INTERFACE_GROUP_ROOT_ASSOCIATION,
                                                               INTERFACE_GROUP_CHILD_ASSOCIATIONS)
          service.call
        end

      end
    end
  end
end
