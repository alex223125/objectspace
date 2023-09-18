module Services
  module Folders
    class Create

      attr_reader :errors, :folder, :target

      def initialize(params, current_user, target, target_type)
        @params = params
        @current_user = current_user
        @target = target
        @target_type = target_type
      end

      def call
        ActiveRecord::Base.transaction do
          binding.pry
          set_target

          binding.pry
          create_folder

          link_current_user_with_all_subfolders

          binding.pry
          @folder.save!
        end
      rescue ActiveRecord::RecordInvalid => e

        binding.pry
        @errors = e.message
        Rails.logger.error(@errors)
      end

      private

      def create_folder
        binding.pry
        if @target_type == "folder"
          @folder = @target_place.subfolders.new(@params)
        elsif @target_type == "repository"
          @folder = @target_place.folders.new(@params)
        end
      end

      def set_target
        if @target_type == "folder"
          @target_place = Folder.where(id: @target).first
        elsif @target_type == "repository"
          @target_place = Repository.where(id: @target).first
        end
      end

      def link_current_user_with_all_subfolders
        binding.pry
        return unless @target_type == "folder"
        # why: folder.root.folder.user_id not faster the folder.user_id
        @folder.user_id = @current_user.id
        @folder.subfolders.each do |subfolder|
          recursively_link_object_with_(subfolder)
        end
      end

      def recursively_link_object_with_(subfolder)
        subfolder.user_id = @current_user.id
        if subfolder.subfolders.any?
          subfolder.subfolders.each do |next_subfolder|
            recursively_link_object_with_(next_subfolder)
          end
        end
      end

    end
  end
end