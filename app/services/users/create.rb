module Services
  module Users
    class Create

      attr_reader :user

      def initialize(user)
        @user = user
      end

      def call
        binding.pry
        create_root_folder
        @user.save
      end

      private

      def create_root_folder
        @user.folders.new(responsibility_type: Folders::ResponsibilityTypeTypes[:user_root])
      end

    end
  end
end