class Algorithms::ControlStructure < ApplicationRecord

  belongs_to :algorithm_version, class_name: "Algorithms::AlgorithmVersion"

  has_many :steps, class_name: "Algorithms::Step"
  accepts_nested_attributes_for :steps, allow_destroy: true

  validates :steps, presence: true
  # why this is here?
  validates_associated :steps

end
