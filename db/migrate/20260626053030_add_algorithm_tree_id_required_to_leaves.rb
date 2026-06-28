class AddAlgorithmTreeIdRequiredToLeaves < ActiveRecord::Migration[7.0]
  def change
    change_column_null :leaves, :algorithm_tree_id, false
  end
end