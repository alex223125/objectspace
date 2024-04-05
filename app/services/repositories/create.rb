module Services
  module Repositories
    class Create

      attr_reader :errors, :repository

      def initialize(params, current_user)
        @params = params
        @current_user = current_user
      end

      def call
        ActiveRecord::Base.transaction do
          binding.pry
          create_repository
          binding.pry
          set_owner
          set_tags

          binding.pry
          @repository.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        binding.pry
        @errors = e.message
        Rails.logger.error(@errors)
      end

      private

      def create_repository
        @repository = @current_user.repositories.new(@params)
      end

      def set_owner
        binding.pry
        @repository.ownerable = @current_user
      end

      def set_tags
        binding.pry
        @repository.tag_list = parse_tags
      end

      def parse_tags
        if @params[:tag_list].present?
          JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
        end
      end

    end
  end
end