class AddAlgorithmTreeToAlgorithmVersion < ActiveRecord::Migration[7.0]
  def change
    default_algorithm_tree = Algorithms::Navigation::AlgorithmTree.new(algorithm_version_title: 'Default Algorithm Tree')
    default_algorithm_tree.save(validate: false)
    id = default_algorithm_tree.id
    add_reference :algorithm_versions, :algorithm_tree, null: false, foreign_key: true, index: true, default: id
  end
end
