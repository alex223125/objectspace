module Users
  class UserSuggestionSerializer < ActiveModel::Serializer
    attributes :value, :name, :avatar, :username


    def value
      object.id
    end

    def avatar
      binding.pry
      # TODO generate this image after save cropped avatar
      image = object.cropped_avatar.variant(resize_to_limit: [64, 64]).try(:processed)
      if image.present?
        path = Rails.application.routes.url_helpers.rails_representation_url(image, only_path: true)
        ActiveStorage::Current.url_options + path
        # Rails.application.routes.url_helpers.rails_representation_url(image, only_path: true)
      end

    end

  end
end
