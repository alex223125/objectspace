module ApplicationHelper
  # include Pagy::Frontend

  def technology_item_link_to(item, html_options = {}, &block)
    if item.class == Articles::Article
      path = article_version_path(username: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Units::Unit
      path = unit_version_path(username: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == Algorithms::Algorithm
      path = algorithm_version_path(username: item.ownerable.ownername, id: item.default_version.slug)
    elsif item.class == SimpleClasses::SimpleClass
      path = simple_class_path(username: item.ownerable.ownername, id: item.slug)
    elsif item.class == Frameworks::Framework
      path = framework_path(username: item.ownerable.ownername, id: item.slug)
    end

    result = link_to(path, html_options, &block)
    result
  end

  # profle image helpers
  def settings_edit_user_avatar(user)
    if user.cropped_avatar.attached?
      binding.pry
      user.cropped_avatar.variant(resize_to_fill: [400, 400])
    end
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


end
