module TechBreadcrumbable
  extend ActiveSupport::Concern

  VERSIONED_TECHNOLOGIES = [Articles::ArticleVersion, Units::UnitVersion, Algorithms::AlgorithmVersion].freeze

  def technology_breadcrumbs(technology)
    # binding.pry
    if technology.class == Algorithms::AlgorithmVersion && technology.try(:algorithm).try(:functional_type) == Algorithms::FunctionalTypes[:class_level]
      simple_class_layer_technology(technology)
    else
      folder_layer_technology(technology)
    end
  end

  def simple_class_layer_technology(technology)
    # can be only one simple class
    interface_member = technology.algorithm.interface_members.first
    interface_group = interface_member.interface_group
    simple_class = interface_member.simple_class

    binding.pry
    current_place = current_place(simple_class)

    # TODO: add methods for this expressions
    if current_place.class == Folder
      current_place_user = current_place.root.repository.user
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      current_place_user = current_place.user
      places_tree = [current_place]
    end

    add_breadcrumb current_place_user.username, dashboard_path(username: current_place_user.username), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_user, place), {link_type: "folder_page"}
    end
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}
    add_breadcrumb interface_group.title, technology_path(interface_group)[:path], {link_type: technology_path(interface_group)[:link_type]}
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  def folder_layer_technology(technology)
    current_place = current_place(technology)

    # TODO: add methods for this expressions
    if current_place.class == Folder
      current_place_user = current_place.root.repository.user
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      current_place_user = current_place.user
      places_tree = [current_place]
    end

    binding.pry
    add_breadcrumb current_place_user.username, dashboard_path(username: current_place_user.username), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_user, place), {link_type: "folder_page"}
    end
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  private

  def place_path(current_place_user, place)
    if place.class == Folder
      target_folder_path(username: current_place_user.username, id: place.slug)
    elsif place.class == Repository
      target_repository_path(username: current_place_user.username, id: place.slug)
    end
  end

  def technology_path(technology)
    if technology.class == Articles::ArticleVersion
     {path: article_version_path(username: technology.owner.ownername,
                                 id: technology.slug),
      link_type: "article_version_page"}
    elsif technology.class == Units::UnitVersion
     {path: unit_version_path(username: technology.owner.ownername, id: technology.slug),
      link_type: "unit_version_page"}
    elsif technology.class == Algorithms::AlgorithmVersion
     {path: algorithm_version_path(username: technology.owner.ownername, id: technology.slug),
      link_type: "algorithm_version_page"}
    elsif technology.class == SimpleClasses::SimpleClass
     {path: simple_class_path(username: technology.owner.ownername, id: technology.slug),
      link_type: "simple_class_page"}
    elsif technology.class == SimpleClasses::InterfaceGroup
      simple_class = technology.simple_class
      {path: simple_class_path(username: simple_class.owner.ownername, id: simple_class.slug),
       link_type: "interface_group_page"}
    elsif technology.class == Frameworks::Framework
     {path: framework_path(username: technology.ownerable.ownername, id: technology.slug),
      link_type: "framework_page"}
    end
  end

  def current_place(technology)
    if VERSIONED_TECHNOLOGIES.include?(technology.class)
      technology.whole_unit.folder || technology.whole_unit.repository
    else
      technology.folder || technology.repository
    end
  end

  def place_title(place)
    place.try(:title) || place.try(:name)
  end

end
