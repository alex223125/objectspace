module DeviseHelper
  # #------Fix Devise form when you want to use in non Devise Controller------
  # #------Without this code you will get undefined var resource--------------
  # def resource_name
  #   :user
  # end
  #
  # def resource
  #   @resource ||= User.new
  # end
  #
  # def devise_mapping
  #   @devise_mapping ||= Devise.mappings[:user]
  # end
end