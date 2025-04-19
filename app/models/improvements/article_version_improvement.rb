class Improvements::ArticleVersionImprovement < ApplicationRecord

  belongs_to :article_version, class_name: "Articles::ArticleVersion"
  belongs_to :improvement, class_name: "Improvements::Improvement"

end
