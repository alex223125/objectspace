module Services
  module Frameworks
    module FrameworkFolders
      class Create

        attr_reader :errors, :framework_folder, :target

        def initialize(params, target_place, creator)
          binding.pry
          @params = params
          @target_place = target_place
          @creator = creator
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            # set_target

            binding.pry
            create_framework_folder
            set_creator
            # link_owner_with_all_subfolders

            binding.pry
            @framework_folder.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_framework_folder
          binding.pry
          @framework_folder = @target_place.subfolders.new(@params)
        end

        def set_creator
          @framework_folder.creator = @creator
        end

        # def set_target
        #   if @target_type == "folder"
        #     @target_place = Folder.where(id: @target).first
        #   elsif @target_type == "repository"
        #     @target_place = Repository.where(id: @target).first
        #   end
        # end

        # DO I NEED THIS FOR FRAMEWORK FOLDERS?
        # def link_owner_with_all_subfolders
        #   binding.pry
        #   return if @target_type == "repository"
        #   # why: folder.root.folder.ownerable not faster then folder.ownerable
        #   @folder.ownerable = @owner
        #   @folder.subfolders.each do |subfolder|
        #     recursively_link_object_with_(subfolder)
        #   end
        # end
        #
        # def recursively_link_object_with_(subfolder)
        #   subfolder.ownerable = @owner
        #
        #   if subfolder.subfolders.any?
        #     subfolder.subfolders.each do |next_subfolder|
        #       recursively_link_object_with_(next_subfolder)
        #     end
        #   end
        # end

      end
    end
  end
end