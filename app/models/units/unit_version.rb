class Units::UnitVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :unit

  has_many :unit_version_unit_usage_examples, class_name: "UnitVersionUnitUsageExample"

  has_many :usage_examples, as: :usage_exampable, class_name: "UsageExample"
  accepts_nested_attributes_for :usage_examples, allow_destroy: true


  has_many :unit_version_usage_examples, class_name: "UsageExamples::UnitVersionUsageExample"
  has_many :usage_examples, through: :unit_version_usage_examples, class_name: "UsageExamples::UsageExample"
  accepts_nested_attributes_for :usage_examples

  # has_many :usage_examples, through: :unit_version_unit_usage_examples, class_name: "UnitUsageExample"
  # accepts_nested_attributes_for :usage_examples

  has_many :unit_version_improvements, class_name: "Improvements::UnitVersionImprovement"
  has_many :improvements, through: :unit_version_improvements, class_name: "Improvements::Improvement"

  # unit can not have substeps
  # has_many :substeps, as: :substepable, class_name: "Algorithms::Substep"
  has_many :simple_objects, as: :instructionable, class_name: "SimpleObjects::SimpleObject"

  has_many :attachments, class_name: "Attachment"
  accepts_nested_attributes_for :attachments, allow_destroy: true

  has_many :comments, :as => :commentable, :dependent => :destroy, class_name: "Comment"

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :unit

  def uniq_key
    class_key + self.uuid
  end

  def class_key
    "unit_version"
  end

  def owner
    self.unit.ownerable
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
