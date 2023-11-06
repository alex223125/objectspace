class Algorithms::Nodes::Step < Algorithms::Nodes::Node

  self.inheritance_column = nil

  belongs_to :control_structure, optional: true

  # cant use with clouser tree
  # acts_as_list scope: :control_structure

  # Units and Algorithms for wrapper type of steps
  # TODO add validation, if step type wrapeer then we should have technology inside of it
  belongs_to :technologiable, polymorphic: true, optional: true

  # moved to node.rb
  # new approach:
  # has_closure_tree order: 'position', numeric_order: true

  # TODO add validation, it step type container, then we should have at least 1 method inside of it

  # We dont have substeps, everything now handled via nodes and subnodes
  # has_many :substeps,
  #          class_name: "Algorithms::Nodes::Step",
  #          foreign_key: "parent_step_id"
  # accepts_nested_attributes_for :substeps
  ####

  # OLD OPTION
  # has_many :substeps, class_name: "Algorithms::Substep"
  # accepts_nested_attributes_for :substeps

  # belongs_to :algorithm_version
  # acts_as_list scope: :algorithm_version

  validates :instruction,
            presence: { message: "Step instruction can not be blank" },
            if: :should_contain_instruction?

  def should_contain_instruction?
    if self.step_functional_type == Steps::FunctionalTypes[:container] ||
      self.step_functional_type == Steps::FunctionalTypes[:wrapper]
      false
    else
      true
    end
  end

  def functional_type
    Steps::FunctionalTypes[self.step_functional_type]
  end

end
