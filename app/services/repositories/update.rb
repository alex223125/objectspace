module Services
  module Repositories
    class Update

      attr_reader :errors, :repository

      def initialize(repository, params)
        @params = params
        @repository = repository
      end

      def call
        ActiveRecord::Base.transaction do
          update_repository
          set_tags
          @repository.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        binding.pry
        @errors = e.message
        Rails.logger.error(@errors)
      end

      private

      def update_repository
        @repository.update(@params)
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