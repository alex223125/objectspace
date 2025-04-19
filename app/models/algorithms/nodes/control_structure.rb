class Algorithms::Nodes::ControlStructure < Algorithms::Nodes::Node

  # belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion"

  # TODO: if initial add validatin that it attached to aglrotihm version, in other cases it should only have parent id

  # TODO: probably we don't need it here, maybe only with foraign key parent_id
  has_many :steps, class_name: "Algorithms::Nodes::Step"
  accepts_nested_attributes_for :steps, allow_destroy: true



#   has_many if_flow_steps
#   else flow steps
#   elsif flow steps

  has_many :conditions, class_name: "Algorithms::Nodes::Condition"
  accepts_nested_attributes_for :conditions, allow_destroy: true

  validates :algorithm_version, presence: true, if: :base_control_structure?

  # validates :steps, presence: true
  # why this is here?
  # validates_associated :steps

  # TODO: if we use singular condition we should have only one condition - validation

  def base_control_structure?
    self.control_structure_functional_type == ControlStructures::FunctionalTypes[:initial_template]
  end

end
