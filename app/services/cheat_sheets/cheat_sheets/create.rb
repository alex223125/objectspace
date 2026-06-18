require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
require "./app/services/concerns/shared/owner_permissionable"

module Services
  module CheatSheets
    module CheatSheets
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable
        include Services::Concerns::Shared::OwnerPermissionable

        attr_reader :errors, :cheat_sheet, :permission

        def initialize(params, target_place, owner, creator)
          @params = params
          @target_place = target_place
          @owner = owner
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_cheat_sheet

            binding.pry
            set_visibility

            binding.pry
            set_place
            set_owner
            set_creator

            binding.pry
            set_tags

            binding.pry
            set_default_version

            binding.pry
            @cheat_sheet.save!

            binding.pry
            create_resource_owner_permission
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @cheat_sheet
        end

        def entity
          @cheat_sheet
        end

        private

        def create_cheat_sheet
          binding.pry
          @cheat_sheet = ::CheatSheets::CheatSheet.new(@params.except(:tag_list))
        end

        def set_visibility
          binding.pry
          @cheat_sheet.visibility_status = ::CheatSheets::VisibilityStatusTypes[:public]
        end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @cheat_sheet.folder = @target_place
          elsif @target_place.class == Repository
            @cheat_sheet.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            container_member = create_container_member
            @cheat_sheet.class_containers << container_member
          elsif @target_place.class == ::SimpleClasses::InterfaceGroup
            interface_member = create_interface_member
            @cheat_sheet.interface_members << interface_member
          end
        end

        def set_default_version
          binding.pry
          @cheat_sheet.default_version = @cheat_sheet.cheat_sheet_versions.first
        end

        def set_owner
          binding.pry
          @cheat_sheet.ownerable = @owner
        end

        def set_creator
          @cheat_sheet.creator = @creator
        end

      end
    end
  end
end
