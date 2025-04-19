module Services
  module ReportsRepositories
    class Create

      attr_reader :errors, :reports_repository

      def initialize(params, current_user)
        binding.pry
        @params = params
        @current_user = current_user
      end

      def call
        ActiveRecord::Base.transaction do
          binding.pry
          create_reports_repository
          binding.pry
          set_owner
          # set_tags

          binding.pry
          @reports_repository.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        binding.pry
        @errors = e.message
        Rails.logger.error(@errors)
      end

      private

      def create_reports_repository
        binding.pry
        @reports_repository = @current_user.reports_repositories.new(@params)
      end

      def set_owner
        binding.pry
        @reports_repository.ownerable = @current_user
      end

      # def set_tags
      #   binding.pry
      #   @reports_repository.tag_list = parse_tags
      # end

      def parse_tags
        if @params[:tag_list].present?
          JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
        end
      end

    end
  end
end