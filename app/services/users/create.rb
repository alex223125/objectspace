module Services
  module Users
    class Create

      attr_reader :user

      DEFAULT_REPORTS_REPOSITORY_TITLE = "Home".freeze
      DEFAULT_REPORTS_REPOSITORY_DESCRIPTION = "This is home repository for reports".freeze

      DEFAULT_TECHNOLOGIES_REPOSITORY_TITLE = "Home".freeze
      DEFAULT_TECHNOLOGIES_REPOSITORY_DESCRIPTION = "This is home repository for technologies".freeze

      DEFAULT_VISIBILITY = false.freeze

      def initialize(user)
        @user = user
      end

      def call
        binding.pry
        create_dashboard
        create_reports_repository
        create_technologies_repository

        binding.pry
        # create_root_folder

        binding.pry
        @user.save
      end

      private

      # def create_root_folder
      #   binding.pry
      #   @user.folders.new(responsibility_type: ::Folders::ResponsibilityTypeTypes[:user_root])
      # end

      def create_dashboard
        @user.build_dashboard
      end

      def create_technologies_repository
        @user.repositories.new(functional_type: ::Repositories::FunctionalTypes[:default_user_technologies_repository],
                               name: DEFAULT_TECHNOLOGIES_REPOSITORY_TITLE,
                               description: DEFAULT_TECHNOLOGIES_REPOSITORY_DESCRIPTION,
                               is_private: DEFAULT_VISIBILITY)

      end

      def create_reports_repository
        binding.pry
        @user.reports_repositories.new(functional_type: ::ReportsRepositories::FunctionalTypes[:default_user_reports_repository],
                                       title: DEFAULT_REPORTS_REPOSITORY_TITLE,
                                       description: DEFAULT_REPORTS_REPOSITORY_DESCRIPTION,
                                       is_private: DEFAULT_VISIBILITY)
      end

    end
  end
end