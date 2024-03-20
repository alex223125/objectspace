class CheatSheets::LinkAttachment < ApplicationRecord
  belongs_to :note
  belongs_to :linkable, polymorphic: true

  def type
    if self.linkable_type == "Articles::Article"
      "article"
    elsif self.linkable_type == "Units::Unit"
      "unit"
    elsif self.linkable_type == "Algorithms::Algorithm"
      "algorithm"
    end
  end
end
