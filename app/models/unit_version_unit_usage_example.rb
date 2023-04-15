class UnitVersionUnitUsageExample < ApplicationRecord

  belongs_to :unit_version, class_name: "Units::UnitVersion"
  belongs_to :unit_usage_example, class_name: "UnitUsageExample"
  # belongs_to :unit, class_name: "Units::Unit", optional: true

end