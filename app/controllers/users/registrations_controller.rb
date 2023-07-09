# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # helper DeviseHelper

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    binding.pry
    build_resource(sign_up_params)

    binding.pry
    service = Services::Users::Create.new(resource)
    service.call
    resource = service.user
    binding.pry
    # resource.save

    binding.pry
    yield resource if block_given?

    binding.pry
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      binding.pry
      respond_with resource, location: new_user_registration_path(resource)
    end
  end

  # GET /resource/edit
  def edit
    binding.pry
    super
  end

  def edit_tos_agreement
    binding.pry
    # @user = User.find_by(id: params["user_id"])
  end

  # PUT /resource
  def update
    binding.pry
    super
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def update_resource(resource, params)
    binding.pry
    if resource.provider == 'google_oauth2'
      params.delete('current_password')
      resource.password = params['password']
      resource.tos_agreement = (params['tos_agreement'] == 1) ? true : false
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end


  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  def configure_sign_up_params
    binding.pry
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username, :email, :password, :password_confirmation, :tos_agreement, :avatar])
  end


  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    binding.pry
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :username, :email, :password, :password_confirmation, :tos_agreement, :avatar])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    dashboard_path(username: resource.username)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
