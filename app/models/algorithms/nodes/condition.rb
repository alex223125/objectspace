class Algorithms::Nodes::Condition < ApplicationRecord

  belongs_to :control_structure, class_name: "Algorithms::Nodes::ControlStructure"

end
