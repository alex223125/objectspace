module Services
  module SimpleClasses
    module SimpleClasses
      class Update

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :simple_class

        def initialize(params, simple_class)
          @params = params
          @simple_class = simple_class
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            update_simple_class
            link_simple_class_with_all_containers
            link_simple_class_with_all_interface_groups

            binding.pry
            set_tags

            binding.pry
            update_related_framework_members

            binding.pry
            @simple_class.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def update_simple_class
          @simple_class.assign_attributes(@params.except(:tag_list))
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

        def set_tags
          binding.pry
          @simple_class.tag_list = parse_tags
        end

        def parse_tags
          if @params[:tag_list].present?
            JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
          end
        end

        def update_related_framework_members
          binding.pry
          @simple_class.framework_members.each do |framework_member|
            binding.pry
            framework_member.title = @simple_class.title
            framework_member.description = @simple_class.description
            framework_member.save!
          end
        end

      end
    end
  end
end
