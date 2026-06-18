require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
require "./app/services/concerns/shared/owner_permissionable"

module Services
  module Units
    module Units
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable
        include ::Services::Concerns::Shared::OwnerPermissionable

        attr_reader :errors, :unit, :permission

        def initialize(params, target_place, creator, owner)
          @params = params
          @target_place = target_place
          @creator = creator
          @owner = owner
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_unit

            binding.pry
            set_usage_unit_example_flag

            binding.pry
            set_owner
            set_creator

            set_place
            set_tags

            binding.pry
            set_visibility

            # link_with_interface_group if @target_interface_group.present?

            binding.pry
            @unit.save!

            binding.pry
            set_default_version

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @unit
        end

        def entity
          @unit
        end

        private

        def create_unit
          binding.pry
          @unit = ::Units::Unit.new(@params.except(:tag_list))
        end

        def set_usage_unit_example_flag
          binding.pry
          @unit.unit_versions.first.usage_examples.each do |example|
            example.is_for_all_versions = true
          end
        end

        def set_visibility
          binding.pry
          @unit.visibility_status = ::Units::VisibilityStatusTypes[:public]
        end

        def set_default_version
          binding.pry
          @unit.default_version_id = @unit.unit_versions.first.id
          @unit.save!
        end

        def set_owner
          @unit.ownerable = @owner
        end

        def set_creator
          binding.pry
          @unit.creator = @creator
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @unit.folder = @target_place
          elsif @target_place.class == Repository
            @unit.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            container_member = create_container_member
            @unit.class_containers << container_member
          elsif @target_place.class == ::SimpleClasses::InterfaceGroup
            interface_member = create_interface_member
            @unit.interface_members << interface_member
          end
        end

        # def link_with_interface_group
        #   interface_member = @target_interface_group.interface_members.new
        #   interface_member.memberable = @unit
        #   @unit.interface_members << interface_member
        # end

      end
    end
  end
end