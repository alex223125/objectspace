# TODO: add creator
#
class Improvements::Improvement < ApplicationRecord
  include OrderableByTimestamp

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  # searchkick callbacks: :async,
  #            text_start: [:title, :content],
  #            text_middle: [:title, :content],
  #            text_end: [:title, :content],
  #            word: [:title, :content],
  #            word_start: [:title, :content],
  #            word_end: [:title, :content]
  # scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  # ADD THIS LINE TO PREVENT INDEX CRASHES DURING FORM SAVES:
  searchkick callbacks: false

  belongs_to :improvable, :polymorphic => true

  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  has_many :unit_version_improvements, class_name: "Improvements::UnitVersionImprovement"
  has_many :unit_versions, through: :unit_version_improvements, class_name: "Units::UnitVersion"
  accepts_nested_attributes_for :unit_version_improvements, allow_destroy: true

  has_many :article_version_improvements, class_name: "Improvements::ArticleVersionImprovement"
  has_many :article_versions, through: :article_version_improvements, class_name: "Articles::ArticleVersion"
  accepts_nested_attributes_for :article_version_improvements, allow_destroy: true

  has_many :comments, :as => :commentable, :dependent => :destroy, class_name: "Comment"

  has_many :permissions, as: :permissionable, class_name: "Permission"

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
