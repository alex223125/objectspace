module Services
  module Users
    class Create

      attr_reader :user

      def initialize(user)
        @user = user
      end

      def call
        binding.pry
        create_dashboard

        binding.pry
        create_root_folder

        binding.pry
        @user.save
      end

      private

      def create_root_folder
        binding.pry
        @user.folders.new(responsibility_type: ::Folders::ResponsibilityTypeTypes[:user_root])
      end

      def create_dashboard
        @user.build_dashboard
      end

    end
  end
end