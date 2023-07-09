class Articles::ArticleVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]


  belongs_to :article, class_name: "Articles::Article"

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :article

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
