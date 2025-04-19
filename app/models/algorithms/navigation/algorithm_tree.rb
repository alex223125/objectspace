class Algorithms::Navigation::AlgorithmTree < ApplicationRecord
  has_one :algorithm_version, class_name: "Algorithms::AlgorithmVersion"
  has_one :leafe, dependent: :destroy, :validate => true

  def tree_root
    leafe
  end

  def leaves_amount
    self.tree_root.self_and_descendants.length
  end

end