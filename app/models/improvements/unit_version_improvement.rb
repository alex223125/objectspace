class Improvements::UnitVersionImprovement < ApplicationRecord

  belongs_to :unit_version, class_name: "Units::UnitVersion"
  belongs_to :improvement, class_name: "Improvements::Improvement"

end