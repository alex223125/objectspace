class AddOriginalNodeIdToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :original_node_id, :integer
  end
end
