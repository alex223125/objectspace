# TODO: add creator
#
class Improvements::Improvement < ApplicationRecord
  include OrderableByTimestamp

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :content],
             text_middle: [:title, :content],
             text_end: [:title, :content],
             word: [:title, :content],
             word_start: [:title, :content],
             word_end: [:title, :content]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :unit, class_name: "Units::Unit"

  has_many :unit_version_improvements, class_name: "Improvements::UnitVersionImprovement"
  has_many :unit_versions, through: :unit_version_improvements, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_version_improvements, allow_destroy: true


  has_many :comments, :as => :commentable, :dependent => :destroy, class_name: "Comment"

  def class_key
    "improvement"
  end

  def uniq_key
    class_key + self.uuid
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
