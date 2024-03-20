module Services
  module CheatSheetGroups
    module CheatSheetGroups
      class Create

        attr_reader :errors, :cheat_sheet_group

        def initialize(params, target_place, current_user)
          @params = params
          @target_place = target_place
          @current_user = current_user
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
          end
        end

        def set_default_version
          binding.pry
          @cheat_sheet_group.default_version = @cheat_sheet_group.cheat_sheet_group_versions.first
        end

        def set_owner
          binding.pry
          @cheat_sheet_group.ownerable = @current_user
        end

        def set_tags
          binding.pry
          @cheat_sheet_group.tag_list = parse_tags
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
