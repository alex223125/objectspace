class UsageExamples::UsageExample < ApplicationRecord

  # belongs_to :usage_exampable, polymorphic: true

  has_many :unit_version_usage_examples
  has_many :unit_versions, through: :unit_version_usage_examples, class_name: "Units::UnitVersion"

end
