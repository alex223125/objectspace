class Algorithms::Substep < ApplicationRecord

  belongs_to :step
  acts_as_list scope: :step

  belongs_to :unit, class_name: "Units::Unit"
  belongs_to :algorithm, class_name: "Algorithms::Algorithm"

end
