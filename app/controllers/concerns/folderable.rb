module Folderable
  # TODO: rename to placable (both foldrs and repositories)
  extend ActiveSupport::Concern

  def target_place
    @target_repository || @target_folder || @target_class_container || @target_interface_group
  end

  private

  # TODO: rename
  def set_target_folder
    binding.pry
    if params[:target_folder] == "user_root"
      @target_folder = current_user.root_folder
    elsif params[:target_folder].present?
      @target_folder = Folder.find_by_uuid(params[:target_folder])
    elsif params[:target_repository].present?
      @target_repository = Repository.find_by_uuid(params[:target_repository])
    elsif params[:target_class_container].present?
      @target_class_container = SimpleClasses::ClassContainer.find_by_uuid(params[:target_class_container])
    elsif params[:target_interface_group].present?
      @target_interface_group = SimpleClasses::InterfaceGroup.find_by_uuid(params[:target_interface_group])
    end
  end

end