module Services
  module UserSettings
    class Update

      attr_reader :errors, :user

      def initialize(user, params, settings_type)
        @user = user
        @params = params
        @settings_type = settings_type
      end

      def call
        ActiveRecord::Base.transaction do
          if @settings_type == "profile_settings"
            binding.pry
            set_attributes

            binding.pry
            set_cropped_avatar
          elsif @settings_type == "account_settings"
            binding.pry
            set_attributes
          end
          binding.pry
          @user.save
        rescue ActiveRecord::RecordInvalid => e
          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end
      end


      private

      def set_attributes
        binding.pry
        @user.assign_attributes(@params.except(:cropped_image_result))
      end

      # attach cropped image
      def set_cropped_avatar
        binding.pry
        if @params[:cropped_image_result].present?
          binding.pry
          cropped_image_base64 = @params[:cropped_image_result].split(',')[1]

          binding.pry
          @user.cropped_avatar.attach(
            io: StringIO.new(Base64.decode64(cropped_image_base64)),
            filename: 'cropped_image.jpeg',
            content_type: 'image/jpeg'
          )
        end
      end
    end
  end
end