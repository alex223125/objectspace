module TechBreadcrumbable
  extend ActiveSupport::Concern

  VERSIONED_TECHNOLOGIES = [Articles::ArticleVersion, Units::UnitVersion, Algorithms::AlgorithmVersion,
                            CheatSheets::CheatSheetVersion, CheatSheetGroups::CheatSheetGroupVersion].freeze

  SIMPLE_CLASS_MEMBER_CLASSES = [SimpleClasses::InterfaceMember, SimpleClasses::ContainerMember].freeze

  def technology_breadcrumbs(technology)
    binding.pry
    if technology.class == Algorithms::AlgorithmVersion && technology.try(:algorithm).try(:functional_type) == Algorithms::FunctionalTypes[:class_level]
      simple_class_layer_technology(technology)
    elsif technology.class == SimpleClasses::ClassContainer
      simple_class_layer_technology_two(technology)
    elsif technology.class == SimpleClasses::InterfaceGroup
      simple_class_layer_interface_group(technology)
    elsif simple_class_member?(technology) || technology.class == SimpleClasses::SimpleClass
      simple_class_layer_technology_three(technology)
    elsif technology.class == Folder || technology.class == Repository
      folder_layer_technology(technology)
    end
  end

  def simple_class_layer_technology_three(target)

    # 0.Detect target type
    if simple_class_member?(target)
      member = target
      # technology = target.memberable
      # technology_version = technology.default_version
    end

    # 1.Set basic layers
    # technology = technology_version.whole_unit
    if target.class == SimpleClasses::InterfaceMember
      interface_group = target.interface_group
      simple_class = interface_group.related_simple_class || interface_group.simple_class
    elsif target.class == SimpleClasses::ContainerMember
      class_container = target.class_container
      simple_class = class_container.related_simple_class || interface_group.simple_class
    elsif target.class == SimpleClasses::SimpleClass
      simple_class = target
    end

    current_place = current_place(simple_class)
    current_place_owner = current_place_owner(current_place)
    places_tree = places_tree(current_place)

    # 2.simple class level path
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}

    binding.pry
    # 3.class containers groups path tree
    if interface_group.present?
      class_container = interface_group.related_class_container || interface_group.class_container
      # DOC: in case of despendants of Main interface group we dont have ClassContainer
      class_containers_path = class_container.try(:self_and_ancestors)
    elsif class_container.present?
      class_containers_path = class_container.self_and_ancestors
    end
    if class_containers_path.present?
      class_containers_path_without_root = class_containers_path.reject {|x| x.root_functional_type?}
      class_containers_path_without_root.reverse.each do |class_container|
        add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
      end
    end

    # 4.interface groups path
    if interface_group.present?
      interface_groups_path = interface_group.self_and_ancestors
      interface_groups_path.reverse.each do |interface_group|
        add_breadcrumb interface_group.title, technology_path(interface_group)[:path], {link_type: technology_path(interface_group)[:link_type]}
      end
    end

    ## 5 memberable path
    if member.present?
      add_breadcrumb member.title, technology_path(member)[:path], {link_type: technology_path(member)[:link_type]}
    end

    ## 5.technology path
    # if technology_version.present?
    #   add_breadcrumb technology_version.title, technology_path(technology_version)[:path], {link_type: technology_path(technology_version)[:link_type]}
    # end
  end

  def simple_class_layer_interface_group(technology)
    class_member = technology
    simple_class = technology.related_simple_class

    current_place = current_place(simple_class)
    current_place_owner = current_place_owner(current_place)
    places_tree = places_tree(current_place)

    # refactor to this for all class-level technologies
    # if technology.class == "AAA"
    #   1 methods
    # elsif technology.class == "BBB"
    #   1 method
    #   2 method
    #   3 method

    # simple class level path
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}

    binding.pry
    # interface groups path tree
    root_class_container = class_member.root.class_container
    # DOC: if no class container found means "root" class_member is Main interface group
    # and it's attached to simple class but not attached to any of ClassContainer
    if root_class_container.present?
      class_containers_path = class_member.root.class_container.self_and_ancestors
      class_containers_path_without_root = class_containers_path.reject {|x| x.root_functional_type?}
      class_containers_path_without_root.reverse.each do |class_container|
        add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
      end
    end

    # interface groups path
    interface_groups_path = class_member.self_and_ancestors
    interface_groups_path_without_root = interface_groups_path.reject {|x| x.root_functional_type?}
    interface_groups_path_without_root.reverse.each do |interface_group|
      add_breadcrumb interface_group.title, technology_path(interface_group)[:path], {link_type: technology_path(interface_group)[:link_type]}
    end

    ## technologyies path
  end


  def simple_class_layer_technology_two(technology)
    class_member = technology
    simple_class = technology.related_simple_class

    current_place = current_place(simple_class)

    if current_place.class == Folder
      current_place_owner = current_place.root.repository.ownerable
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      current_place_owner = current_place.ownerable
      places_tree = [current_place]
    end

    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}
    binding.pry
    path_without_root = class_member.ancestors.reject {|x| x.root_functional_type?}
    path_without_root.reverse.each do |class_container|
      add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
    end
    add_breadcrumb class_member.title, technology_path(class_member)[:path], {link_type: technology_path(class_member)[:link_type]}
  end

  # interface member breadcrumbs
  def simple_class_layer_technology(technology)
    # can be only one simple class
    interface_member = technology.algorithm.interface_members.first
    interface_group = interface_member.interface_group
    simple_class = interface_member.simple_class

    binding.pry
    current_place = current_place(simple_class)

    # TODO: add methods for this expressions
    if current_place.class == Folder
      current_place_owner = current_place.root.repository.ownerable
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      current_place_owner = current_place.ownerable
      places_tree = [current_place]
    end

    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}
    add_breadcrumb interface_group.title, technology_path(interface_group)[:path], {link_type: technology_path(interface_group)[:link_type]}
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  def folder_layer_technology(technology)
    current_place = current_place(technology)

    # TODO: add methods for this expressions
    if current_place.class == Folder
      current_place_user = current_place.root.repository.ownerable
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      binding.pry
      current_place_user = current_place.ownerable
      places_tree = [current_place]
    end

    binding.pry
    add_breadcrumb current_place_user.ownername, dashboard_path(username: current_place_user.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_user, place), {link_type: "folder_page"}
    end
    binding.pry
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  private

  def simple_class_member?(technology)
    SIMPLE_CLASS_MEMBER_CLASSES.include?(technology.class)
  end

  def current_place_owner(place)
    if place.class == Folder
      place.root.repository.ownerable
    elsif place.class == Repository
      place.ownerable
    end
  end

  def places_tree(place)
    if place.class == Folder
      place.self_and_ancestors.reverse
    elsif place.class == Repository
      [place]
    end
  end

  def place_path(current_place_user, place)
    if place.class == Folder
      target_folder_path(ownername: current_place_user.username, id: place.slug)
    elsif place.class == Repository
      target_repository_path(ownername: current_place_user.username, id: place.slug)
    end
  end


  def technology_path(technology)
    if technology.class == Articles::ArticleVersion
     {path: article_version_path(ownername: technology.owner.ownername,
                                 id: technology.slug),
      link_type: "article_version_page"}
    # Doc: When we have reference to whole group, we create link to default version
    elsif technology.class == Units::Unit
      {path: unit_version_path(ownername: technology.owner.ownername, id: technology.default_version.slug),
        link_type: "unit_version_page"}
    elsif technology.class == Units::UnitVersion
     {path: unit_version_path(ownername: technology.owner.ownername, id: technology.slug),
      link_type: "unit_version_page"}
    elsif technology.class == Algorithms::AlgorithmVersion
     {path: algorithm_version_path(ownername: technology.owner.ownername, id: technology.slug),
      link_type: "algorithm_version_page"}
    elsif technology.class == CheatSheets::CheatSheetVersion
      {path: cheat_sheet_version_path(ownername: technology.owner.ownername, id: technology.slug),
        link_type: "cheat_sheet_version_page"}
    elsif technology.class == CheatSheetGroups::CheatSheetGroupVersion
      {path: cheat_sheet_group_version_path(ownername: technology.owner.ownername, id: technology.slug),
        link_type: "cheat_sheet_group_version_page"}
    elsif technology.class == SimpleClasses::SimpleClass
     {path: simple_class_path(ownername: technology.owner.ownername, id: technology.slug),
      link_type: "simple_class_page"}
    elsif technology.class == SimpleClasses::InterfaceGroup
      simple_class = technology.simple_class || technology.related_simple_class
      {path: interface_group_path(ownername: simple_class.owner.ownername, id: technology.slug),
       link_type: "interface_group_page"}
    elsif technology.class == SimpleClasses::InterfaceMember
      simple_class = technology.simple_class
      {path: interface_member_path(ownername: simple_class.owner.ownername, id: technology.slug),
       link_type: "interface_group_page"}
    elsif technology.class == SimpleClasses::ClassContainer
      simple_class = technology.related_simple_class
      {path: class_container_path(ownername: simple_class.owner.ownername, id: technology.slug),
       link_type: "class_container_page"}
    elsif technology.class == Frameworks::Framework
     {path: framework_path(ownername: technology.owner.ownername, id: technology.slug),
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
