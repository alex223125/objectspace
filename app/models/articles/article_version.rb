class Articles::ArticleVersion < ApplicationRecord

  belongs_to :article, class_name: "Articles::Article"

end
