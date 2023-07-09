module Services
  module Frameworks
    module Frameworks
      class Create

        CLASS_CONTAINER_ROOT_ASSOCIATION = "class_containers".freeze
        CLASS_CONTAINER_CHILD_ASSOCIATIONS = "containers".freeze

        INTERFACE_GROUP_ROOT_ASSOCIATION = "interface_groups".freeze
        INTERFACE_GROUP_CHILD_ASSOCIATIONS = "groups".freeze

        attr_reader :errors, :framework

        def initialize(params, target_folder, current_user)
          @params = params
          @target_folder = target_folder
          @current_user = current_user
        end

        def call
          ActiveRecord::Base.transaction do
            create_framework
            link_framework_with_all_containers
            link_framework_with_all_interface_groups

            binding.pry
            set_owner
            set_folder
            set_tags

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
          @framework = ::Frameworks::Framework.new(@params.except(:tag_list))
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

        def set_owner
          @framework.ownerable = @current_user
        end

        def set_folder
          @framework.folder = @target_folder
        end

        def set_tags
          binding.pry
          @framework.tag_list = parse_tags
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
