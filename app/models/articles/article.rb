class Articles::Article < ApplicationRecord

  has_many :article_versions, class_name: "Articles::ArticleVersion", dependent: :destroy
  accepts_nested_attributes_for :article_versions

  def default_version
    Articles::ArticleVersion.find_by(id: self.default_version_id)
  end

end
