class AdminUsers::SessionsController < Devise::SessionsController
  layout 'application'

  protected

  # Перанакіраванне пасля паспяховага ўваходу
  def after_sign_in_path_for(resource)
    admin_articles_path
  end
end
