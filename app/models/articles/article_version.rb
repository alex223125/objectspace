class Articles::ArticleVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]


  belongs_to :article, class_name: "Articles::Article"

  has_many :attachments, as: :attachable, class_name: "Attachment"

  has_many :attachments, class_name: "Attachment", foreign_key: :article_version_id
  accepts_nested_attributes_for :attachments, allow_destroy: true

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :article

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
