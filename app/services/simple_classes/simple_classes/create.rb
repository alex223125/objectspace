module Services
  module SimpleClasses
    module SimpleClasses
      class Create

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :simple_class

        def initialize(params)
          @params = params
        end

        def call
          ActiveRecord::Base.transaction do
            create_simple_class
            link_simple_class_with_all_containers
            link_simple_class_with_all_interface_groups
            binding.pry
            @simple_class.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_simple_class
          @simple_class = ::SimpleClasses::SimpleClass.new(@params)
        end

        def link_simple_class_with_all_containers
          service = Services::Shared::LinkGroupsWithObject.new(@simple_class,
                                                                    CLASS_CONTAINER_ROOT_ASSOCIATION,
                                                                    CLASS_CONTAINER_CHILD_ASSOCIATIONS)
          service.call
        end

        def link_simple_class_with_all_interface_groups
          service = Services::Shared::LinkGroupsWithObject.new(@simple_class,
                                                                    INTERFACE_GROUP_ROOT_ASSOCIATION,
                                                                    INTERFACE_GROUP_CHILD_ASSOCIATIONS)
          service.call
        end

      end
    end
  end
end
