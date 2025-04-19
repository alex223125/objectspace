class AddAlgorithmTreeIdToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :algorithm_tree_id, :integer
  end
end
