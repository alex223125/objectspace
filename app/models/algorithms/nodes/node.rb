class Algorithms::Nodes::Node < ApplicationRecord

  # for creation logic
  attr_accessor :parent_id_dynamic_node,
                :current_node_frontend_id

  has_closure_tree order: 'position', numeric_order: true

  # TODO add validation, it step type container, then we should have at least 1 method inside of it
  has_many :subnodes, -> { order 'nodes.position ASC' },
           class_name: "Algorithms::Nodes::Node",
           foreign_key: "parent_id"
  accepts_nested_attributes_for :subnodes, allow_destroy: true

  has_many :attachments, class_name: "Attachment"
  accepts_nested_attributes_for :attachments, allow_destroy: true

  def functional_type_id
    if self.type == "Algorithms::Nodes::Step"
      self.step_functional_type
    elsif self.type == "Algorithms::Nodes::ControlStructure"
      self.control_structure_functional_type
    end
  end

end
