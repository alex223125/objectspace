require "./app/services/concerns/shared/owner_permissionable"
require "./app/services/concerns/technologies/memberable"

module Services
  module SimpleClasses
    module SimpleClasses
      class Create
        include Services::Concerns::Shared::OwnerPermissionable
        include ::Services::Concerns::Technologies::Memberable

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :simple_class, :permission

        def initialize(params, target_place, creator, owner)
          @params = params
          @target_place = target_place
          @creator = creator
          @owner = owner
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_simple_class
            create_simple_class_interface
            link_simple_class_with_all_containers
            link_simple_class_with_all_interface_groups

            binding.pry
            set_owner
            set_creator

            binding.pry
            set_place

            binding.pry
            set_tags

            binding.pry
            set_related_simple_class_for_root_container
            set_related_simple_class_for_root_interface_group

            binding.pry
            @simple_class.save!

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        # DOC: Exception from standarts, in this scenario Decision Box acts as technology
        def technology
          @simple_class
        end

        def entity
          @simple_class
        end

        private

        def create_simple_class
          @simple_class = ::SimpleClasses::SimpleClass.new(@params.except(:tag_list))
        end

        def create_simple_class_interface
          @simple_class.build_simple_class_interface
        end

        # TODO: move into concernt for both create and update actions, or use hierarhy Update < Actions
        def link_simple_class_with_all_containers
          binding.pry
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

        def set_owner
          binding.pry
          @simple_class.ownerable = @owner
        end

        def set_creator
          binding.pry
          @simple_class.creator = @creator
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @simple_class.folder = @target_place
          elsif @target_place.class == Repository
            @simple_class.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            binding.pry
            container_member = create_container_member
            binding.pry
            @simple_class.framework_container_members << container_member

            @simple_class.related_framework = @target_place.closest_framework
          elsif @target_place.class == ::Frameworks::FrameworkFolder
            binding.pry
            framework_folder_member = create_framework_folder_member
            @simple_class.framework_members << framework_folder_member

            binding.pry
            @simple_class.related_framework = @target_place.closest_framework
          end
        end

        def set_tags
          binding.pry
          @simple_class.tag_list = parse_tags
        end

        def parse_tags
          if @params[:tag_list].present?
            JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
          end
        end

        def set_related_simple_class_for_root_container
          binding.pry
          class_container = @simple_class.class_containers.find{|a| a.functional_type == ::ClassContainers::FunctionalTypes[:root_class_container]}

          binding.pry
          class_container.related_simple_class = @simple_class
        end

        def set_related_simple_class_for_root_interface_group
          binding.pry
          interface_group = @simple_class.interface_groups.find{|a| a.functional_type == ::InterfaceGroups::FunctionalTypes[:root]}

          binding.pry
          interface_group.related_simple_class = @simple_class
        end

      end
    end
  end
end
