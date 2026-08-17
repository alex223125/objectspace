class AdminUsers::RegistrationsController < Devise::RegistrationsController
  layout 'application' # Або 'admin', калі для аўтарызацыі асобны шаблон

  protected

  # Перанакіраванне пасля паспяховай рэгістрацыі (напрыклад, у панэль артыкулаў)
  def after_sign_up_path_for(resource)
    admin_article_versions_path
  end

  # Перанакіраванне, калі ўліковы запіс чакае пацверджання
  def after_inactive_sign_up_path_for(resource)
    new_admin_user_session_path
  end
end
