class Algorithms::Step < ApplicationRecord

  belongs_to :control_structure
  acts_as_list scope: :control_structure

  has_many :substeps, class_name: "Algorithms::Substep"
  accepts_nested_attributes_for :substeps

  # belongs_to :algorithm_version
  # acts_as_list scope: :algorithm_version

end
