module Containerable
  extend ActiveSupport::Concern

  def target_place
    @target_simple_class || @target_class_container || @target_interface_group
  end

  def containerable_back_path
    if target_place.class == SimpleClasses::InterfaceGroup
      @back_path = interface_group_path(ownername: target_place.related_simple_class.ownerable.ownername, id: target_place.slug)
    elsif target_place.class == SimpleClasses::ClassContainer
      @back_path = class_container_path(ownername: target_place.related_simple_class.ownerable.ownername, id: target_place.slug)
    end
  end

  private

  def set_target_place
    binding.pry
    if params[:target_simple_class].present?
      @target_simple_class = SimpleClasses::SimpleClass.find_by_uuid(params[:target_simple_class])
    elsif params[:target_class_container].present?
      @target_class_container = SimpleClasses::ClassContainer.find_by_uuid(params[:target_class_container])
    elsif params[:target_interface_group].present?
      @target_interface_group = SimpleClasses::InterfaceGroup.find_by_uuid(params[:target_interface_group])
    end
  end
end