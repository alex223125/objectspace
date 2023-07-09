module Folderable
  extend ActiveSupport::Concern

  def set_target_folder
    binding.pry
    @target_folder = Folder.find(params[:target_folder])
  end

end