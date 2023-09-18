module Folderable
  extend ActiveSupport::Concern

  def set_target_folder
    binding.pry
    if params[:target_folder] == "user_root"
      @target_folder = current_user.root_folder
    elsif params[:target_folder].present?
      @target_folder = Folder.find(params[:target_folder])
    end
  end

end