class Articles::ArticleVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]


  belongs_to :article, class_name: "Articles::Article"

  # WHY 2 attachments?
  has_many :attachments, as: :attachable, class_name: "Attachment"

  has_many :attachments, class_name: "Attachment", foreign_key: :article_version_id
  accepts_nested_attributes_for :attachments, allow_destroy: true

  validates :title, presence: true, allow_blank: false

  alias_method :whole_unit, :article

  def class_key
    "article_version"
  end

  def uniq_key
    class_key + self.uuid
  end

  def all_versions
    self.article.article_versions
  end

  private

  # TODO: change id on uuid
  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

  def search_data
    {
      id: id,
      uuid: uuid,
      title: title,
      content: content,
      sources: sources,
      additional_information: additional_information,
      slug: slug,
      article_id: article_id,
      article_title: article&.title,
      created_at: created_at,
      updated_at: updated_at
    }
  end

end
