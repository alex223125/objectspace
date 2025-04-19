module Services
  module Folders
    class Create

      attr_reader :errors, :folder, :target

      def initialize(params, owner, target, target_type)
        binding.pry
        @params = params
        @owner = owner
        @target = target
        @target_type = target_type
      end

      def call
        ActiveRecord::Base.transaction do
          binding.pry
          set_target

          binding.pry
          create_folder

          binding.pry
          link_owner_with_all_subfolders

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
          @folder = @target_place.repository_folders.new(@params)
        elsif @target_type == "reports_repository"
          @folder = @target_place.reports_repository_folders.new(@params)
        end
      end

      def set_target
        if @target_type == "folder"
          @target_place = Folder.where(id: @target).first
        elsif @target_type == "repository"
          @target_place = Repository.where(id: @target).first
        elsif @target_type == "reports_repository"
          @target_place = ReportsRepository.where(id: @target).first
        end
      end

      def link_owner_with_all_subfolders
        binding.pry
        # return if @target_type == "repository" || @target_type == "reports_repository"
        # why: folder.root.folder.ownerable not faster then folder.ownerable
        @folder.ownerable = @owner
        @folder.subfolders.each do |subfolder|
          recursively_link_object_with_(subfolder)
        end
      end

      def recursively_link_object_with_(subfolder)
        subfolder.ownerable = @owner

        if subfolder.subfolders.any?
          subfolder.subfolders.each do |next_subfolder|
            recursively_link_object_with_(next_subfolder)
          end
        end
      end

    end
  end
end