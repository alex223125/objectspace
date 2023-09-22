class Attachment < ApplicationRecord
  belongs_to :node, class_name: "Algorithms::Nodes::Node"
  belongs_to :attachable, polymorphic: true

  def type
    if self.attachable_type == "Articles::Article"
      "article"
    end
  end
end
