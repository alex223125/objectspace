module RecursiveParametersBuilder
  # recursive_path = [:post]
  # recursive_key = :comment_attributes
  # recursive_node_permitted_params = [:id, :_destroy, :parameterized_type, :parameterized_id, :name, :value, :is_encrypted, :base_param_id, :parent_param_id]
  #
  def build_recursive_params(recursive_key:, parameters:, permitted_attributes:)
    template = { recursive_key => permitted_attributes }

    nested_permit_list = template.deep_dup
    current_node = nested_permit_list[recursive_key]

    nested_count = parameters.to_s.scan(/#{recursive_key}/).count
    (1..nested_count).each do |i|
      new_element = template.deep_dup
      current_node << new_element
      current_node = new_element[recursive_key]
    end
    nested_permit_list
  end
end