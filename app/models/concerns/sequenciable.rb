module Sequenciable
  extend ActiveSupport::Concern

  # TODO: move to service objects ?
  def next_node
    position = self.position
    next_position = position + 1

    binding.pry
    # 1.Check if next sibling present and use it
    next_sibling = self.siblings.where(position: next_position).first

    binding.pry
    return next_sibling if next_sibling.present?

    binding.pry
    # 2.Check if next sibling of parent node present and use it if
    # no siblings found on current node level
    binding.pry
    parent_node = self.parent
    # DOC: means that we hit top of the algorithm tree and there are no next nodes to go
    binding.pry
    return nil if parent_node.functional_type == Algorithms::Nodes::Node::CONTROL_STRUCTURE_INITIAL_TEMPLATE_FUNCTIONAL_TYPE
    binding.pry
    position_of_parent = parent_node.position
    binding.pry
    next_position = position_of_parent + 1
    binding.pry
    next_sibling = parent_node.siblings.where(position: next_position).first
    binding.pry
    if next_sibling.present?
      binding.pry
      if next_sibling.functional_type == Algorithms::Nodes::Node::STEP_REGULAR_FUNCTIONAL_TYPE
        next_sibling
      elsif next_sibling.functional_type == Algorithms::Nodes::Node::STEP_WRAPPER_FUNCTIONAL_TYPE
        next_sibling
      elsif next_sibling.functional_type == Algorithms::Nodes::Node::STEP_CONTAINER_FUNCTIONAL_TYPE
        #DOC In case of container we should switch to first step of container
        next_sibling.children.first
      end
    else
      nil
    end
  end

  # def last_node_in_initial_control_strucutre?(node)
  #   if self.siblings.where(position: next_position).first == 0 &&
  # end

  def previous_node
    position = self.position
    return nil if position == 0
    previous_position = position - 1
    # 1.Check if previous sibling present and use it
    previous_sibling = self.siblings.where(position: previous_position).first
    return previous_sibling if previous_sibling.present?

    # 2.Check if previous sibling of parent node present and use it if
    # no siblings found on current node level
    parent_node = self.parent
    # DOC: means that we hit top of the algorithm tree and there are no next nodes to go
    return nil if parent_node.functional_type == CONTROL_STRUCTURE_INITIAL_TEMPLATE_FUNCTIONAL_TYPE
    position_of_parent = parent_node.position
    #DOC: mean we dealing with first step of algorithm and there is not previous steps
    return nil if position_of_parent == 0
    previous_position = position_of_parent - 1
    previous_sibling = parent_node.siblings.where(position: previous_position).first
    if previous_sibling.present?
      if previous_sibling.functional_type == STEP_REGULAR_FUNCTIONAL_TYPE
        previous_sibling
      elsif previous_sibling.functional_type == STEP_WRAPPER_FUNCTIONAL_TYPE
        previous_sibling
      elsif previous_sibling.functional_type == STEP_CONTAINER_FUNCTIONAL_TYPE
        #DOC In case of container we should switch to last step of container
        previous_sibling.children.last
      end
    else
      nil
    end
  end
end