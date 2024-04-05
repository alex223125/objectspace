require "./app/services/concerns/technologies/taggable"
require "./app/services/concerns/technologies/memberable"
module Services
  module CheatSheetGroups
    module CheatSheetGroups
      class Create
        include ::Services::Concerns::Technologies::Taggable
        include ::Services::Concerns::Technologies::Memberable

        attr_reader :errors, :cheat_sheet_group

        def initialize(params, target_place, creator, owner)
          @params = params
          @target_place = target_place
          @creator = creator
          @owner = owner
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_cheat_sheet_group

            # binding.pry
            # set_visibility

            binding.pry
            set_place

            set_owner
            set_creator

            binding.pry
            set_tags

            binding.pry
            set_default_version

            binding.pry
            @cheat_sheet_group.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        def technology
          @cheat_sheet_group
        end

        private

        def create_cheat_sheet_group
          binding.pry
          @cheat_sheet_group = ::CheatSheetGroups::CheatSheetGroup.new(@params.except(:tag_list))
        end

        # def set_visibility
        #   binding.pry
        #   @cheat_sheet.visibility_status = ::CheatSheets::VisibilityStatusTypes[:public]
        # end

        def set_place
          binding.pry
          if @target_place.class == Folder
            @cheat_sheet_group.folder = @target_place
          elsif @target_place.class == Repository
            @cheat_sheet_group.repository = @target_place
          elsif @target_place.class == ::SimpleClasses::ClassContainer
            container_member = create_container_member
            @cheat_sheet_group.class_containers << container_member
          elsif @target_place.class == ::SimpleClasses::InterfaceGroup
            interface_member = create_interface_member
            @cheat_sheet_group.interface_members << interface_member
          end
        end

        def set_default_version
          binding.pry
          @cheat_sheet_group.default_version = @cheat_sheet_group.cheat_sheet_group_versions.first
        end

        def set_owner
          binding.pry
          @cheat_sheet_group.ownerable = @owner
        end

        def set_creator
          binding.pry
          @cheat_sheet_group.creator = @creator
        end

      end
    end
  end
end
