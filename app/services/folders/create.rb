module Services
  module Folders
    class Create

      attr_reader :errors, :folder

      def initialize(params, current_user, target_folder_id)
        @params = params
        @current_user = current_user
        @target_folder_id = target_folder_id
      end

      def call
        ActiveRecord::Base.transaction do
          binding.pry
          set_target_folder

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
        @folder = @target_folder.subfolders.new(@params)
      end

      def set_target_folder
        @target_folder = Folder.where(id: @target_folder_id).first
      end

      def link_current_user_with_all_subfolders
        binding.pry
        # why: folder.root.folder.user_id not faster the folder.user_id
        @folder.user = @current_user
        @folder.subfolders.each do |subfolder|
          recursively_link_object_with_(subfolder)
        end
      end

      def recursively_link_object_with_(subfolder)
        subfolder.user = @current_user
        if subfolder.subfolders.any?
          subfolder.subfolders.each do |next_subfolder|
            recursively_link_object_with_(next_subfolder)
          end
        end
      end

    end
  end
end