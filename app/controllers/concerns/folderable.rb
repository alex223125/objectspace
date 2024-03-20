module Folderable
  # TODO: rename to placable (both foldrs and repositories)
  extend ActiveSupport::Concern

  def set_target_folder
    binding.pry
    if params[:target_folder] == "user_root"
      @target_folder = current_user.root_folder
    elsif params[:target_folder].present?
      @target_folder = Folder.find_by_uuid(params[:target_folder])
    elsif params[:target_repository].present?
      @target_repository = Repository.find_by_uuid(params[:target_repository])
    end
  end

  def target_place
    @target_repository || @target_folder
  end

end