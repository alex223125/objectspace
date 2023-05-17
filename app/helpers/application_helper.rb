module ApplicationHelper
  # include Pagy::Frontend

  def type_readable_name(simple_class)
    type = simple_class.type
    SimpleClasses::TypeTypes.meta(type)[:readable_name]
  end

end
