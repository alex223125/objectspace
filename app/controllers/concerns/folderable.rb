module Folderable
  # TODO: rename to placable (both foldrs and repositories)
  extend ActiveSupport::Concern

  def set_target_folder
    binding.pry
    if params[:target_folder] == "user_root"
      @target_folder = current_user.root_folder
    elsif params[:target_folder].present?
      @target_folder = Folder.find(params[:target_folder])
    elsif params[:target_repository].present?
      @target_repository = Repository.find(params[:target_repository])
    end
  end

end