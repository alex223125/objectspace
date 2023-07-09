# frozen_string_literal: true

class Users::UserSettingsController < ApplicationController

  before_action :set_user, only: %i[ show update ]

  def profile
    binding.pry
    @user = current_user
    add_breadcrumb current_user.username, dashboard_path(username: current_user.username)
    add_breadcrumb "Profile settings", user_settings_profile_path(username: current_user.username)
  end

  def account
    binding.pry
    @user = current_user
    add_breadcrumb current_user.username, dashboard_path(username: current_user.username)
    add_breadcrumb "Account settings", user_settings_account_path(username: current_user.username)
  end

  def update
    binding.pry
    if params[:settings_type] == "profile_settings"
      permitted_params = profile_settings_params
    elsif params[:settings_type] == "account_settings"
      permitted_params = account_settings_params
    end

    binding.pry
    service = Services::UserSettings::Update.new(@user, permitted_params, params[:settings_type])
    service.call

    if params[:settings_type] == "profile_settings"
      success_notice = "Profile settings was successfully updated."
      success_path = user_settings_profile_path(service.user.username)
      error_path = :profile
    elsif params[:settings_type] == "account_settings"
      success_notice = "Account settings was successfully updated."
      success_path = user_settings_account_path(service.user.username)
      @user = service.user
      error_path = :account
    end


    respond_to do |format|
      if service.errors.blank?
        format.html { redirect_to success_path, notice: success_notice }
      else
        format.html { render error_path, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def profile_settings_params
    params.require(:user).permit(:name, :biography, :website, :company,
                                 :location, :is_email_public, :avatar, :cropped_image_result)
  end

  def account_settings_params
    params.require(:user).permit(:username)
  end


end