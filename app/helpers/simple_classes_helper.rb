module SimpleClassesHelper

  CLASS_CONTAINERS_NESTED_LEVELS_COUNT_BEGINNING = 1.freeze
  CLASS_CONTAINERS_ALLOWED_NESTED_LEVELS_AMOUNT = 10.freeze

  INTERFACE_GROUPS_NESTED_LEVELS_COUNT_BEGINNING = 1.freeze
  INTERFACE_GROUPS_ALLOWED_NESTED_LEVELS_AMOUNT = 10.freeze

  FOLDERS_NESTED_LEVELS_COUNT_BEGINNING = 1.freeze
  FOLDERS_ALLOWES_NESTED_LEVELS_AMOUNT = 10.freeze


  def member_custom_link_to(member, html_options = {}, &block)
    if member.class == Units::Unit
      path = unit_unit_version_path(member.default_version)
    elsif member.class == Algorithms::Algorithm
      path = algorithm_algorithm_version_path(member.default_version)
    elsif member.class == SimpleClasses::SimpleClass
      path = simple_class_simple_class_path(member)
    elsif member.class == SimpleClasses::ClassContainer
      path = simple_class_class_container_path(member)
    end

    result = link_to(path, html_options, &block)
    result
  end

end