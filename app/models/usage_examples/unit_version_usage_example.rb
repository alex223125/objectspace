class UsageExamples::UnitVersionUsageExample < ApplicationRecord
  belongs_to :unit_version, class_name: "Units::UnitVersion"
  belongs_to :usage_example
end
