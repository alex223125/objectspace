class Algorithms::AlgorithmVersion < ApplicationRecord

  belongs_to :algorithm

  has_many :control_structures, class_name: "Algorithms::ControlStructure"
  accepts_nested_attributes_for :control_structures

  # has_many :steps, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

end
