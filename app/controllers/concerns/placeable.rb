module Placeable
  extend ActiveSupport::Concern

  def target_place
    binding.pry
    @target_repository || @target_folder || @target_class_container ||
        @target_interface_group || @target_framework_folder || @target_framework_interface ||
        @target_simple_class_interface
  end

  private

  def set_target_place
    binding.pry
    if params[:target_folder] == "user_root"
      @target_folder = current_user.root_folder
    elsif params[:target_folder].present?
      @target_folder = Folder.find_by_uuid(params[:target_folder])
    elsif params[:target_repository].present?
      @target_repository = Repository.find_by_uuid(params[:target_repository])
    elsif params[:target_class_container].present?
      @target_class_container = SimpleClasses::ClassContainer.find_by_uuid(params[:target_class_container])
      if @target_class_container.present?
        @simple_class = @target_class_container.closest_simple_class
        @framework = @target_class_container.closest_framework
      end
    elsif params[:target_interface_group].present?
      @target_interface_group = SimpleClasses::InterfaceGroup.find_by_uuid(params[:target_interface_group])
      if @target_interface_group.present?
        @simple_class = @target_interface_group.closest_simple_class
        @framework = @target_interface_group.closest_framework
      end
    elsif params[:target_framework_folder].present?
      binding.pry
      @target_framework_folder = Frameworks::FrameworkFolder.find_by_uuid(params[:target_framework_folder])
    elsif params[:target_framework_interface].present?
      binding.pry
      @target_framework_interface = Frameworks::FrameworkInterface.find_by_uuid(params[:target_framework_interface])
    elsif params[:target_simple_class_interface].present?
      binding.pry
      @target_simple_class_interface = SimpleClasses::SimpleClassInterface.find_by_uuid(params[:target_simple_class_interface])
    end

  end

end