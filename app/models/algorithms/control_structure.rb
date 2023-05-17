class Algorithms::ControlStructure < ApplicationRecord

  belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion"

  has_many :steps, class_name: "Algorithms::Step"
  accepts_nested_attributes_for :steps

  validates :steps, presence: true
  validates_associated :steps

end
