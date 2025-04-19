module TechBreadcrumbable
  extend ActiveSupport::Concern

  VERSIONED_TECHNOLOGIES = [Articles::ArticleVersion, Units::UnitVersion, Algorithms::AlgorithmVersion,
                            CheatSheets::CheatSheetVersion, CheatSheetGroups::CheatSheetGroupVersion].freeze

  UNITED_TECHNOLOGIES = [Articles::Article, Units::Unit, Algorithms::Algorithm,
                            CheatSheets::CheatSheet, CheatSheetGroups::CheatSheetGroup].freeze

  SIMPLE_CLASS_MEMBER_CLASSES = [SimpleClasses::InterfaceMember, SimpleClasses::ContainerMember].freeze

  FRAMEWORK_MEMBER_CLASSES = [Frameworks::FrameworkMember].freeze

  ALGORITHM_VERSION_NODES_CLASSES = [Algorithms::Nodes::Step, Algorithms::Nodes::ControlStructure].freeze

  def technology_breadcrumbs(technology, scenario: nil)
    binding.pry
    if technology.class == Algorithms::AlgorithmVersion &&
        (technology.try(:algorithm).try(:functional_type) == Algorithms::FunctionalTypes[:class_level])
      simple_class_interface_algorithm_breadcrumbs(technology)
    elsif algorithm_version_node?(technology)
      algorithm_version_node_options(technology)
    elsif technology.class == SimpleClasses::ClassContainer
      binding.pry
      simple_class_layer_technology_two(technology)
    elsif technology.class == SimpleClasses::InterfaceGroup
      binding.pry
      simple_class_layer_interface_group(technology)
    elsif simple_class_member?(technology) || technology.class == SimpleClasses::SimpleClass
      binding.pry
      class_layer_technology_three(technology)
    elsif technology.class == SimpleClasses::SimpleClassAttribute
      binding.pry
      simple_class_layer_attribute_path(technology)
    elsif technology.class == Folder || technology.class == Repository
      binding.pry
      place_layer(technology)
    elsif technology.class == Algorithms::AlgorithmVersion && scenario == "list_of_algorithm_version_steps"
      binding.pry
      algorithm_version_steps_path(technology)
    elsif VERSIONED_TECHNOLOGIES.include?(technology.class)
      binding.pry
      place_layer_technology(technology)
    elsif technology.class == Frameworks::Framework
      class_layer_technology_three(technology)
    elsif technology.class == Improvements::Improvement
      # improvement_path(technology)
      improvable = technology.improvable
      class_layer_technology_three(improvable, technology)
    elsif technology.class == Frameworks::FrameworkFolder
      framework_folder_breadcrumbs(technology)
    elsif technology.class == Frameworks::FrameworkMember
      binding.pry
      framework_member_path_breadcrumbs(technology)
    elsif technology.class == AlgorithmReports::LoggingIntroductionStep
      binding.pry
      source_location = technology.algorithm_report.duplicate_algorithm_version.algorithm.source_location
      source_location_class = source_location.class
      if source_location_class == Folder || source_location_class == Repository
        binding.pry
        algorithm_version_introduction_step_breadcrumbs_path(technology)
      elsif source_location_class == SimpleClasses::ContainerMember || source_location_class == SimpleClasses::InterfaceMember
        binding.pry
        class_layer_technology_three(source_location, technology)
      end
    end
  end

  def report_breadcrumbs(report)
    if report.class == AlgorithmReports::AlgorithmReport
      algorithm_report_breadcrumbs(report)
    end
  end

  private

  def algorithm_version_node_options(node)
    binding.pry
    source_location = node.root.closest_algorithm_version.algorithm.source_location
    source_location_class = source_location.class

    if source_location_class == Folder || source_location_class == Repository
      binding.pry
      algorithm_version_node_breadcrumbs_path(node)
    elsif source_location_class == SimpleClasses::ContainerMember ||
        source_location_class == SimpleClasses::InterfaceMember
      binding.pry
      class_layer_technology_three(source_location, node)
    elsif source_location_class == Frameworks::FrameworkInterface
      binding.pry
      framework_interface_layer_algorithm_version_node_breadcrumbs_path(node)
    end
  end

  def framework_interface_layer_algorithm_version_node_breadcrumbs_path(node)
    # 1 user + repository + folders
    folder_layer_chunk_path(node)
    # 2.Link to framework
    current_place = current_place(node)
    add_breadcrumb current_place.framework.title, technology_path(current_place.framework)[:path], {link_type: technology_path(current_place.framework)[:link_type]}
    # 3.Link to framework interface
    add_breadcrumb "Framework Interface", technology_path(current_place.framework)[:path], {link_type: technology_path(current_place.framework)[:link_type]}
    # 4.Link to algorithm
    algorithm_version = node.closest_algorithm_version
    add_breadcrumb algorithm_version.title, technology_path(algorithm_version)[:path], {link_type: technology_path(algorithm_version)[:link_type]}
    # # 5.Link to step
    add_breadcrumb node.title, technology_path(node)[:path], {link_type: technology_path(node)[:link_type]}
  end

  def algorithm_report_breadcrumbs(technology)
    # 1 user
    # 2 reports repositories
    # 3 repository
    # 4 folder (if exists)
    folder_layer_chunk_path(technology)
    # 4 link to report
    add_breadcrumb technology.title,
                   technology_path(technology)[:path],
                   {link_type: technology_path(technology)[:link_type]}
  end

  # def algorithm_version_step(technology)
  #
  # end

  # DOC: refactor
  def simple_class_layer_attribute_path(simple_class_attribute)
    simple_class = simple_class_attribute.simple_classes
    if simple_class_attribute.class_container.present?
      class_container = simple_class_attribute.class_container
    else
      class_container = nil
    end

    # 1. folder level path
    folder_layer_chunk_path(simple_class)
    # 1.simple class level path
    simple_class_chunk_path(simple_class)
    # 2.class containers groups path tree
    class_container_chunk_path(interface_group: nil, class_container: class_container)

    # 3.path to all attributes
    add_breadcrumb "Characteristics",
                   simple_class_simple_class_attributes_path(target_class_container: class_container,
                                                             target_simple_class: simple_class_attribute.simple_class),
                   {link_type: "characteristics_page"}

    # 4.path to simple_class_attribute
    add_breadcrumb simple_class_attribute.title,
                   technology_path(simple_class_attribute)[:path],
                   {link_type: technology_path(simple_class_attribute)[:link_type]}
  end

  # DOC: refactor
  def class_layer_technology_three(target, part_of_target = nil)

    binding.pry
    # 0.Detect target type
    if simple_class_member?(target)
      member = target
    elsif united_technology?(target)
      member = target
    end

    binding.pry
    # 0.Prepare data for next steps
    # technology = technology_version.whole_unit
    if target.class == SimpleClasses::InterfaceMember
      binding.pry
      interface_group = target.interface_group
      class_layer_entity = interface_group.related_class_layer_entity
    elsif target.class == SimpleClasses::ContainerMember
      binding.pry
      class_container = target.class_container
      class_layer_entity = class_container.related_class_layer_entity

      interface_group = nil
    elsif target.class == SimpleClasses::SimpleClass
      binding.pry
      class_layer_entity = target

      interface_group = nil
      class_container = nil
    elsif target.class == Frameworks::Framework
      binding.pry
      class_layer_entity = target

      interface_group = nil
      class_container = nil
    else
      class_layer_entity = target

      interface_group = nil
      class_container = nil
    end

    binding.pry
    # 1 user + repository + folders
    folder_layer_chunk_path(class_layer_entity)

    binding.pry

    # 2 Class layer entities (SimpleClass and Framework part of the path)
    related_framework = class_layer_entity.related_framework if class_layer_entity.class == SimpleClasses::SimpleClass
    if related_framework.present?
      # DOC: Case 1: When we have SimpleClasses::SimpleClass which is inside Frameworks::Framework during path to target
      framework_chunk_path(related_framework)
      simple_class_chunk_path(class_layer_entity)
    else
      # DOC: Case 2: When we have target which inside or Framework or SimpleClass
      # 2. option 1: simple class level path
      simple_class_chunk_path(class_layer_entity) if class_layer_entity.class == SimpleClasses::SimpleClass
      # 2. option 2: framework level path
      framework_chunk_path(class_layer_entity) if class_layer_entity.class == Frameworks::Framework
    end

    binding.pry
    # 3.class containers groups path tree
    if interface_group.present? || class_container.present?
      class_container_chunk_path(interface_group: interface_group, class_container: class_container)
    end

    binding.pry
    # 4.interface groups path
    if interface_group.present?
      interface_group_chunk_path(interface_group)
    end

    ## 5 memberable path
    if member.present?
      add_breadcrumb member.title, technology_path(member)[:path], {link_type: technology_path(member)[:link_type]}
    end

    ## 6 Part of memberable technology group (for Steps in will be step)
    if part_of_target.present?
      if algorithm_version_node?(part_of_target)
        add_breadcrumb "Steps", technology_path(member)[:path],
                       {link_type: technology_path(member)[:link_type]}
      elsif part_of_target.class == Improvements::Improvement
        add_breadcrumb "Improvements", technology_path(member)[:path],
                       {link_type: technology_path(member)[:link_type]}
      elsif part_of_target.class == AlgorithmReports::LoggingIntroductionStep
        add_breadcrumb "Steps", technology_path(member)[:path],
                       {link_type: technology_path(member)[:link_type]}
      end
    end

    ## 7 Part of memberable technology (Step from AlgorithmVersion for example)
    if part_of_target.present?
      add_breadcrumb part_of_target.title, technology_path(part_of_target)[:path],
                     {link_type: technology_path(part_of_target)[:link_type]}
    end
  end

  # DOC: refactor
  def simple_class_layer_interface_group(technology)
    binding.pry
    class_member = technology

    binding.pry
    simple_class = technology.related_simple_class

    binding.pry
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

    binding.pry
    # simple class level path
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end

    binding.pry
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}

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

  def framework_folder_breadcrumbs(technology)
    # class_member = technology
    # class_layer_entity = technology.related_class_layer_entity
    framework_folder = technology
    framework = technology.root.framework


    binding.pry
    # current_place = current_place(class_layer_entity)
    current_place = framework_folder.parent

    # binding.pry
    # if current_place.class == Folder
    #
    #   binding.pry
    #   current_place_owner = current_place.root.repository.ownerable
    #   places_tree = current_place.self_and_ancestors.reverse
    # elsif current_place.class == Repository
    #
    #   binding.pry
    #   current_place_owner = current_place.ownerable
    #   places_tree = [current_place]
    # end

    current_place_owner = framework.ownerable

    binding.pry
    # DOC: we don't need "Main" folder appear in breadcrumbs
    places_tree = current_place.self_and_ancestors.reverse.select{|folder| folder.functional_type != FrameworkFolders::FunctionalTypes[:root]}

    binding.pry
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    add_breadcrumb framework.title, technology_path(framework)[:path],
                   {link_type: technology_path(framework)[:link_type]}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb framework_folder.title, technology_path(framework_folder)[:path],
                   {link_type: technology_path(framework_folder)[:link_type]}
  end

  # DOC: refactor
  def simple_class_layer_technology_two(technology)
    class_member = technology
    class_layer_entity = technology.related_class_layer_entity

    binding.pry
    current_place = current_place(class_layer_entity)

    binding.pry
    if current_place.class == Folder

      binding.pry
      current_place_owner = current_place.root.repository.ownerable
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository

      binding.pry
      current_place_owner = current_place.ownerable
      places_tree = [current_place]
    end

    binding.pry
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
    add_breadcrumb class_layer_entity.title, technology_path(class_layer_entity)[:path], {link_type: technology_path(class_layer_entity)[:link_type]}

    path_without_root = class_member.ancestors.reject {|x| x.root_functional_type?}
    path_without_root.reverse.each do |class_container|
      add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
    end
    add_breadcrumb class_member.title, technology_path(class_member)[:path], {link_type: technology_path(class_member)[:link_type]}
  end

  # DOC: refactor
  # interface member breadcrumbs
  def simple_class_interface_algorithm_breadcrumbs(algorithm)
    # 1 user + repository + folders
    folder_layer_chunk_path(algorithm)
    # # 2.Link to framework
    current_place = current_place(algorithm)
    add_breadcrumb current_place.simple_class.title, technology_path(current_place.simple_class)[:path], {link_type: technology_path(current_place.simple_class)[:link_type]}
    # 3.Link to framework interface
    add_breadcrumb "Decision Box Interface", technology_path(current_place.simple_class)[:path], {link_type: technology_path(current_place.simple_class)[:link_type]}
    # 4.Link to algorithm
    add_breadcrumb algorithm.title, technology_path(algorithm)[:path], {link_type: technology_path(algorithm)[:link_type]}
  end

  # DOC: for technologies which in folder or repository
  def place_layer_technology(technology)
    binding.pry
    folder_layer_chunk_path(technology)

    binding.pry
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    # if versioned_technology?(technology)
    #   add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    # elsif algorithm_version_node?(technology)
      # algorithm_version = technology.root.algorithm_version
      # add_breadcrumb "Steps", algorithm_steps_path(algorithm_version_id: algorithm_version.slug),
      #                {link_type: "algorithm_version_steps_index"}
      # add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    # end
  end

  def algorithm_version_introduction_step_breadcrumbs_path(technology)
    folder_layer_chunk_path(technology)

    algorithm_version = technology.algorithm_version
    add_breadcrumb "Steps", algorithm_steps_path(algorithm_version_id: algorithm_version.slug),
                   {link_type: "algorithm_version_steps_index"}
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  def algorithm_version_node_breadcrumbs_path(technology)
    folder_layer_chunk_path(technology)

    algorithm_version = technology.root.algorithm_version
    add_breadcrumb "Steps", algorithm_steps_path(algorithm_version_id: algorithm_version.slug),
                   {link_type: "algorithm_version_steps_index"}
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  #DOC: only for "Steps" page for algorithm versions
  def algorithm_version_steps_path(technology)
    folder_layer_chunk_path(technology)
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
    add_breadcrumb "Steps", algorithm_steps_path(algorithm_version_id: technology.slug),
                   {link_type: "algorithm_version_steps_index"}
  end

  # DOC: for folders and repositories
  def place_layer(place)
    current_place = place.folder || place.repository

    # TODO: add methods for this expressions
    if current_place.class == Folder
      current_place_user = current_place.root.repository.ownerable
      places_tree = current_place.self_and_ancestors.reverse
    elsif current_place.class == Repository
      current_place_user = current_place.ownerable
      places_tree = [current_place]
    end

    add_breadcrumb current_place_user.ownername, dashboard_path(username: current_place_user.ownername), {link_type: "profile_page"}
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_user, place), {link_type: "folder_page"}
    end
    add_breadcrumb place.title, technology_path(place)[:path], {link_type: technology_path(place)[:link_type]}
  end


  def class_container_chunk_path(interface_group: nil, class_container: nil)
    if interface_group.present?
      class_container = interface_group.related_class_container || interface_group.class_container
      # DOC: in case of despendants of Main interface group we dont have ClassContainer
      class_containers_path = class_container.try(:self_and_ancestors)
    elsif class_container.present?
      class_containers_path = class_container.self_and_ancestors
    end
    if class_containers_path.present?
      binding.pry
      class_containers_path_without_root = class_containers_path.reject {|x| x.root_functional_type?}

      binding.pry
      class_containers_path_without_root.reverse.each do |class_container|
        add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
      end
    end
  end

  def framework_folders_chunk_path(framework)
    root_framework_folder = framework.root_framework_folder
    framework_folders_path = root_framework_folder.self_and_ancestors
    framework_folders_path_without_root = framework_folders_path.reject {|x| x.root_functional_type?}

    framework_folders_path_without_root.reverse.each do |framework_folder|
      add_breadcrumb framework_folder.title, technology_path(framework_folder)[:path],
                     {link_type: technology_path(framework_folder)[:link_type]}
    end

    # if interface_group.present?
    #   class_container = interface_group.related_class_container || interface_group.class_container
    #   # DOC: in case of despendants of Main interface group we dont have ClassContainer
    #   class_containers_path = class_container.try(:self_and_ancestors)
    # elsif class_container.present?
    #   class_containers_path = class_container.self_and_ancestors
    # end
    # if class_containers_path.present?
    #   binding.pry
    #   class_containers_path_without_root = class_containers_path.reject {|x| x.root_functional_type?}
    #
    #   binding.pry
    #   class_containers_path_without_root.reverse.each do |class_container|
    #     add_breadcrumb class_container.title, technology_path(class_container)[:path], {link_type: technology_path(class_container)[:link_type]}
    #   end
    # end
  end



  # DOC: user + type of repositories + repository + folders
  def folder_layer_chunk_path(technology)
    binding.pry
    current_place = current_place(technology)

    binding.pry
    current_place_owner = current_place_owner(current_place)

    binding.pry
    places_tree = places_tree(current_place)

    binding.pry
    add_breadcrumb current_place_owner.ownername, dashboard_path(username: current_place_owner.ownername), {link_type: "profile_page"}

    binding.pry
    if current_place.class == Repository
      add_breadcrumb "Technologies repositories", dashboard_path(username: current_place_owner.ownername), {link_type: "dashboard_page"}
    elsif current_place.class == ReportsRepository
      add_breadcrumb "Reports repositories", dashboard_path(username: current_place_owner.ownername), {link_type: "dashboard_page"}
    elsif current_place.class == Frameworks::FrameworkInterface || current_place.class == SimpleClasses::SimpleClassInterface
      binding.pry
      # 1.Link to repository or folder where framework placed
      entity = current_place.try(:framework) || current_place.try(:simple_class)
      location = entity.location
      if location.class == Repository
        binding.pry
        add_breadcrumb "Technologies repositories", dashboard_path(username: current_place_owner.ownername), {link_type: "dashboard_page"}
      elsif location.class == ReportsRepository
        add_breadcrumb "Reports repositories", dashboard_path(username: current_place_owner.ownername), {link_type: "dashboard_page"}
      end
    end

    binding.pry
    places_tree.each do |place|
      add_breadcrumb place_title(place), place_path(current_place_owner, place), {link_type: "folder_page"}
    end
  end

  def simple_class_chunk_path(simple_class)
    add_breadcrumb simple_class.title, technology_path(simple_class)[:path], {link_type: technology_path(simple_class)[:link_type]}
  end

  def framework_chunk_path(framework)
    add_breadcrumb framework.title, technology_path(framework)[:path], {link_type: technology_path(framework)[:link_type]}
  end

  def interface_group_chunk_path(interface_group)
    interface_groups_path = interface_group.self_and_ancestors
    interface_groups_path_without_root = interface_groups_path.reject {|x| x.root_functional_type?}
    interface_groups_path_without_root.reverse.each do |interface_group|
      add_breadcrumb interface_group.title, technology_path(interface_group)[:path], {link_type: technology_path(interface_group)[:link_type]}
    end
  end

  def current_place_owner(place)
    binding.pry
    if place.class == Folder
      place.root.repository.ownerable
    elsif place.class == Repository
      place.ownerable
    elsif place.class == SimpleClasses::ClassContainer
      place.closest_class_layer_entity.ownerable
    elsif place.class == Frameworks::FrameworkInterface
      place.framework.ownerable
    elsif place.class == ReportsRepository
      place.ownerable
    elsif place.class == SimpleClasses::SimpleClassInterface
      place.simple_class.ownerable
    end
  end

  def places_tree(place)
    binding.pry
    if place.class == Folder
      binding.pry
      place.self_and_ancestors.reverse
    elsif place.class == Repository
      binding.pry
      [place]
    elsif place.class == SimpleClasses::ClassContainer
      binding.pry
      location = place.closest_class_layer_entity.location
      # DOC: Warning! Recursion
      places_tree(location)
    elsif place.class == Frameworks::FrameworkInterface
      location = place.framework.location
      if location.class == Folder
        repository = location.root.parent_repository
        folders = location.self_and_descendants
        [repository] + [folders]
      elsif location.class == Repository
        [place.framework.location]
      end
    elsif place.class == SimpleClasses::SimpleClassInterface
      location = place.simple_class.location
      if location.class == Folder
        repository = location.root.parent_repository
        folders = location.self_and_descendants
        [repository] + [folders]
      elsif location.class == Repository
        [place.simple_class.location]
      end
    elsif place.class == ReportsRepository
      [place]
    end
  end

  def place_path(current_place_user, place)
    if place.class == Folder
      target_folder_path(ownername: current_place_user.username, id: place.slug)
    elsif place.class == Repository
      target_repository_path(ownername: current_place_user.username, id: place.slug)
    elsif place.class == Frameworks::FrameworkFolder
      framework_folder_path(ownername: current_place_user.username, id: place.slug)
    elsif place.class == Frameworks::Framework
      framework_path(ownername: current_place_user.username, id: place.slug)
    elsif place.class == Frameworks::FrameworkInterface
      framework_path(ownername: current_place_user.username, id: place.framework.slug)
    elsif place.class == ReportsRepository
      target_reports_repository_path(ownername: current_place_user.username, id: place.slug)
    end
  end


  def technology_path(technology)
    binding.pry
    if technology.class == Articles::Article
      {path: article_version_path(ownername: technology.owner.ownername,
                                  id: technology.default_version.slug),
       link_type: "article_version_page"}
    elsif technology.class == Articles::ArticleVersion
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
    elsif algorithm_version_node?(technology)
      binding.pry
      {path: algorithm_version_step_path(ownername: technology.root.algorithm_version.algorithm.ownerable.ownername,
                                         algorithm_version_id: technology.root.algorithm_version.slug,
                                         id: technology.slug),
       link_type: "algorithm_version_step_page"}
    elsif technology.class == CheatSheets::CheatSheetVersion
      {path: cheat_sheet_version_path(ownername: technology.owner.ownername, id: technology.slug),
        link_type: "cheat_sheet_version_page"}
    elsif technology.class == CheatSheetGroups::CheatSheetGroupVersion
      {path: cheat_sheet_group_version_path(ownername: technology.owner.ownername, id: technology.slug),
        link_type: "cheat_sheet_group_version_page"}
    elsif technology.class == SimpleClasses::SimpleClass
     {path: simple_class_path(ownername: technology.owner.ownername, id: technology.slug),
      link_type: "simple_class_page"}
    elsif technology.class == SimpleClasses::SimpleClassAttribute
      simple_class = technology.simple_class || technology.related_simple_class
      {path: simple_class_attribute_path(ownername: simple_class.owner.ownername, class_id: simple_class.slug, id: technology.slug),
       link_type: "simple_class_attribute_page"}
    elsif technology.class == SimpleClasses::InterfaceGroup
      class_layer_entity = technology.related_class_layer_entity
      {path: interface_group_path(ownername: class_layer_entity.owner.ownername, id: technology.slug),
       link_type: "interface_group_page"}
    elsif technology.class == SimpleClasses::InterfaceMember
      closest_class_layer_entity = technology.interface_group.related_class_layer_entity
      {path: interface_member_path(ownername: closest_class_layer_entity.owner.ownername, id: technology.slug),
       link_type: "interface_group_page"}
    elsif technology.class == SimpleClasses::ClassContainer
      class_layer_entity = technology.related_class_layer_entity
      {path: class_container_path(ownername: class_layer_entity.owner.ownername, id: technology.slug),
       link_type: "class_container_page"}
    elsif technology.class == SimpleClasses::ContainerMember
      class_layer_entity = technology.class_container.related_class_layer_entity
      {path: container_member_path(ownername: class_layer_entity.owner.ownername, id: technology.slug),
       link_type: "container_member_page"}
    elsif technology.class == Frameworks::Framework
      {path: framework_path(ownername: technology.owner.ownername, id: technology.slug),
       link_type: "framework_page"}
    elsif technology.class == Improvements::Improvement
      improvable = technology.improvable
      {path: improvement_show_path(technology_name: improvable.slug, id: technology.slug),
       link_type: "improvement_page"}
    elsif technology.class == Frameworks::FrameworkFolder
      {path: framework_folder_path(ownername: technology.root.framework.owner.ownername, id: technology.slug),
       link_type: "framework_folder_page"}
    elsif technology.class == Frameworks::FrameworkMember
      {path: framework_member_path(ownername: technology.closest_framework.owner.ownername, id: technology.slug),
       link_type: "framework_member_page"}
    elsif technology.class == AlgorithmReports::LoggingIntroductionStep
      {path: algorithm_reports_algorithm_execution_initial_place_path(uuid: technology.algorithm_report.uuid),
       link_type: "algorithm_report_introduction_step"}
    elsif technology.class == AlgorithmReports::AlgorithmReport
      {path: algorithm_report_path(ownername: technology.ownerable.ownername, id: technology.slug),
       link_type: "algorithm_report_page"}
    end


  end

  # TODO: refacotr usage
  def current_place(technology)
    binding.pry
    if versioned_technology?(technology)
      binding.pry
      whole_unit = technology.whole_unit
      whole_unit.folder || whole_unit.repository || whole_unit.framework_interface || whole_unit.simple_class_interface
    elsif algorithm_version_node?(technology)
      binding.pry
      algorithm = technology.root.algorithm
      algorithm.folder || algorithm.repository || algorithm.framework_interface || algorithm.simple_class
    elsif technology.class == Algorithms::IntroductionStep
      technology.algorithm.folder || technology.algorithm.repository
    elsif technology.class == SimpleClasses::SimpleClass && technology.related_framework.present?
      binding.pry
      framework = technology.related_framework
      framework.folder || framework.repository
    elsif technology.class == SimpleClasses::SimpleClass || technology.class == Frameworks::Framework
      binding.pry
      technology.folder || technology.repository
    elsif united_technology?(technology)
      technology.folder || technology.repository
    elsif technology.class == AlgorithmReports::AlgorithmReport
      technology.folder || technology.reports_repository
    end
  end

  def place_title(place)
    place.try(:title) || place.try(:name)
  end

  def simple_class_member?(technology)
    SIMPLE_CLASS_MEMBER_CLASSES.include?(technology.class)
  end

  def framework_member?(technology)
    FRAMEWORK_MEMBER_CLASSES.include?(technology.class)
  end

  def versioned_technology?(technology)
    VERSIONED_TECHNOLOGIES.include?(technology.class)
  end

  def algorithm_version_node?(technology)
    ALGORITHM_VERSION_NODES_CLASSES.include?(technology.class)
  end

  def united_technology?(technology)
    UNITED_TECHNOLOGIES.include?(technology.class)
  end



  def framework_member_path_breadcrumbs(target, part_of_target = nil)

    binding.pry
    # 0.Detect target type
    if framework_member?(target)
      member = target
    end

    binding.pry
    # 0.Prepare data for next steps
    # technology = technology_version.whole_unit
    framework = member.closest_framework

    binding.pry
    # 1 user + repository + folders
    folder_layer_chunk_path(framework)

    binding.pry
    # 2 Class layer entities (SimpleClass and Framework part of the path)
    framework_chunk_path(framework) if framework.class == Frameworks::Framework

    binding.pry
    # 3.framework folders path tree
    framework_folders_chunk_path(framework)

    binding.pry
    ## 5 memberable path
    if member.present?
      add_breadcrumb member.title, technology_path(member)[:path], {link_type: technology_path(member)[:link_type]}
    end
  end


end
