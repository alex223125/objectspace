class RemoveAlgorithmVersionIdFromAlgorithmTrees < ActiveRecord::Migration[7.0]
  def change
    remove_column :algorithm_trees, :algorithm_version_id, :integer
  end
end
