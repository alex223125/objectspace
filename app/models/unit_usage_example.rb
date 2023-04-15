class UnitUsageExample < ApplicationRecord

  belongs_to :unit, class_name: "Units::Unit"

  ## there will be ability to select specific version of unit to update
  # belongs_to :unit_version, class_name: "Units::UnitVersion"
  has_many :unit_version_unit_usage_examples
  has_many :unit_versions, through: :unit_version_unit_usage_examples, class_name: "Units::UnitVersion"
end
