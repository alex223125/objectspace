class Attachment < ApplicationRecord

  # polymorphic to attachment
  belongs_to :attachable, polymorphic: true

  # belongs to any of these models
  # TODO: add validation that it should be at leas one of these belongs_to attached during creation
  belongs_to :node, class_name: "Algorithms::Nodes::Node", optional: true
  belongs_to :unit_version, class_name: "Units::UnitVersion", optional: true
  belongs_to :article_version, class_name: "Articles::ArticleVersion", optional: true

  def type
    if self.attachable_type == "Articles::Article"
      "article"
    end
  end
end