class Units::UnitVersion < ApplicationRecord

  belongs_to :unit

  has_many :unit_version_unit_usage_examples, class_name: "UnitVersionUnitUsageExample"
  has_many :unit_usage_examples, through: :unit_version_unit_usage_examples, class_name: "UnitUsageExample"
  accepts_nested_attributes_for :unit_usage_examples

  has_many :unit_version_improvements, class_name: "UnitVersionImprovement"
  has_many :improvement, through: :unit_version_improvements, class_name: "Improvement"

end
