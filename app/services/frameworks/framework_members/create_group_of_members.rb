module Services
  module Frameworks
    module FrameworkMembers
      class CreateGroupOfMembers

        attr_reader :errors, :target_framework_folder

        def initialize(params, target_framework_folder)
          binding.pry
          @params = params
          @target_framework_folder = target_framework_folder
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            create_framework_members

            binding.pry
            set_content


            binding.pry
            @target_framework_folder.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private

        def create_framework_members
          binding.pry
          framework_members_params = @params[:framework_folder][:framework_members_attributes].values
          @target_framework_folder.framework_members.new(framework_members_params)
        end

        def set_content
          binding.pry
          @target_framework_folder.framework_members.select{|member| member.id == nil}.each do |framework_member|
            framework_member.title = framework_member.framework_memberable.title
            framework_member.description = framework_member.framework_memberable.description
          end
        end

      end
    end
  end
end