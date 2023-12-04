class Units::UnitVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :unit

  has_many :unit_version_unit_usage_examples, class_name: "UnitVersionUnitUsageExample"

  has_many :usage_examples, as: :usage_exampable, class_name: "UsageExample"
  accepts_nested_attributes_for :usage_examples

  # has_many :usage_examples, through: :unit_version_unit_usage_examples, class_name: "UnitUsageExample"
  # accepts_nested_attributes_for :usage_examples

  has_many :unit_version_improvements, class_name: "UnitVersionImprovement"
  has_many :improvement, through: :unit_version_improvements, class_name: "Improvement"

  # unit can not have substeps
  # has_many :substeps, as: :substepable, class_name: "Algorithms::Substep"
  has_many :simple_objects, as: :instructionable, class_name: "SimpleObjects::SimpleObject"

  has_many :attachments, class_name: "Attachment"
  accepts_nested_attributes_for :attachments, allow_destroy: true

  # include PgSearch::Model
  # pg_search_scope :english_global_search,
  #                 against: {
  #                   title: 'A',
  #                   instruction: 'B',
  #                   solves_the_problem: 'C',
  #                   sources: 'D'
  #                 },
  #                 using: {
  #                   tsearch: {
  #                     dictionary: 'english',
  #                     tsvector_column: 'searchable',
  #                     any_word: true,
  #                     prefix: true
  #                   }
  #                 }


  alias_method :whole_unit, :unit

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
