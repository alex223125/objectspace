module TechBreadcrumbable
  extend ActiveSupport::Concern

  VERSIONED_TECHNOLOGIES = [Articles::ArticleVersion, Units::UnitVersion, Algorithms::AlgorithmVersion].freeze

  def technology_breadcrumbs(technology)
    binding.pry
    current_folder = current_folder(technology)
    current_folder_user = current_folder.user
    folders_tree_without_root = current_folder.folders_tree_without_root.reverse

    add_breadcrumb current_folder_user.username, dashboard_path(username: current_folder_user.username), {link_type: "profile_page"}
    folders_tree_without_root.each do |folder|
      add_breadcrumb folder.title, target_folder_path(username: current_folder_user.username, id: folder.slug), {link_type: "folder_page"}
    end
    add_breadcrumb technology.title, technology_path(technology)[:path], {link_type: technology_path(technology)[:link_type]}
  end

  private

  def technology_path(technology)
    @technology_path ||= begin
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
                              link_type: "class_page"}
                           elsif technology.class == Frameworks::Framework
                             {path: framework_path(username: technology.ownerable.ownername, id: technology.slug),
                              link_type: "framework_page"}
                           end
                         end
  end



  def current_folder(technology)
    if VERSIONED_TECHNOLOGIES.include?(technology.class)
      technology.whole_unit.folder
    else
      technology.folder
    end
  end

end