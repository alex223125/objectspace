module ApplicationHelper
  # include Pagy::Frontend

  # doc: to open in a new window
  def technology_item_link_to(item, html_options = {}, &block)
    if item.class == Articles::Article
      path = article_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Units::Unit
      path = unit_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Algorithms::Algorithm
      path = algorithm_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == CheatSheets::CheatSheet
      path = cheat_sheet_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == CheatSheetGroups::CheatSheetGroup
      path = cheat_sheet_group_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == SimpleClasses::SimpleClass
      path = simple_class_path(ownername: item.ownerable.ownername, id: item.slug)
    elsif item.class == SimpleClasses::ClassContainer
      simple_class = item.related_simple_class
      path = class_container_path(ownername: simple_class.ownerable.ownername, id: item.slug)
    elsif item.class == Frameworks::Framework
      path = framework_path(ownername: item.ownerable.ownername, id: item.slug)
    end

    result = link_to(path, html_options, &block)
    result
  end

  # doc: to open in the same window
  def technology_item_path_to(item)
    if item.class == Articles::Article
      path = article_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Units::Unit
      path = unit_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Algorithms::Algorithm
      path = algorithm_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == CheatSheets::CheatSheet
      path = cheat_sheet_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == CheatSheetGroups::CheatSheetGroup
      path = cheat_sheet_group_version_path(ownername: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == SimpleClasses::SimpleClass
      path = simple_class_path(ownername: item.ownerable.ownername, id: item.slug)
    elsif item.class == SimpleClasses::ClassContainer
      simple_class = item.related_simple_class
      path = class_container_path(ownername: simple_class.ownerable.ownername, id: item.slug)
    elsif item.class == Frameworks::Framework
      path = framework_path(ownername: item.ownerable.ownername, id: item.slug)
    end

    result = path
    result
  end

  # profle image helpers
  def settings_edit_user_avatar(user)
    if user.cropped_avatar.attached?
      binding.pry
      user.cropped_avatar.variant(resize_to_fill: [400, 400])
    end
  end

  # DOC:helper to create link from list of technologies in SimpleClass interface_group or
  # class_container to position where technology placed
  def simple_class_member_path_to(member)
    binding.pry
    if member.class == SimpleClasses::InterfaceMember
      interface_group = member.interface_group
      binding.pry
      simple_class = interface_group.related_simple_class || interface_group.simple_class

      binding.pry
      path = interface_member_path(ownername: simple_class.ownerable.ownername, id: member.slug)

    elsif member.class == SimpleClasses::ContainerMember
      class_container = member.class_container
      simple_class = class_container.related_simple_class || class_container.simple_class
      path = container_member_path(ownername: simple_class.ownerable.ownername, id: member.slug)
    end

    result = path
    result
  end

  # def user_avatar(user, size=40)
  #   if user.cropped_avatar.attached?
  #     binding.pry
  #     user.cropped_avatar.variant(resize_to_limit: [size, size])
  #   else
  #     gravatar_image_url(user.email, size: size)
  #   end
  # end

  # def member_custom_link_to(member, html_options = {}, &block)
  #   if member.class == Units::Unit
  #     path = unit_unit_version_path(member.default_version)
  #   elsif member.class == Algorithms::Algorithm
  #     path = algorithm_algorithm_version_path(member.default_version)
  #   elsif member.class == SimpleClasses::SimpleClass
  #     path = simple_class_simple_class_path(member)
  #   elsif member.class == SimpleClasses::ClassContainer
  #     path = simple_class_class_container_path(member)
  #   end
  #
  #   result = link_to(path, html_options, &block)
  #   result
  # end

  def polymorphic_path_builder(record, options = {})
    binding.pry
    if record.class == Units::UnitVersion
      binding.pry
      #link to create action
      unit_unit_version_comments_path(unit_version_id: record.id)
      # other classes
    else
      polymorphic_url(record, options)
    end
  end

  # DOC: back to place from which we started creation of tech
  def back_to_place_path(target_folder, target_repository)
    if target_folder.present?
      current_place_owner = target_folder.root.repository.ownerable
      target_folder_path(ownername: current_place_owner.ownername, id: target_folder.id)
    elsif target_repository.present?
      current_place_owner = target_repository.ownerable
      target_repository_path(ownername: current_place_owner.ownername, id: target_repository.slug)
    end
  end
end
