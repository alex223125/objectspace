module Services
  module SimpleClasses
    module SimpleClasses
      class Create

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :simple_class

        def initialize(params, target_folder, current_user)
          @params = params
          @target_folder = target_folder
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_simple_class
            link_simple_class_with_all_containers
            link_simple_class_with_all_interface_groups

            binding.pry
            set_owner
            set_folder
            set_tags

            binding.pry
            @simple_class.save!
          end
        rescue ActiveRecord::RecordInvalid => e
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_simple_class
          @simple_class = ::SimpleClasses::SimpleClass.new(@params.except(:tag_list))
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
          @simple_class.ownerable = @current_user
        end

        def set_folder
          @simple_class.folder = @target_folder
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

      end
    end
  end
end
