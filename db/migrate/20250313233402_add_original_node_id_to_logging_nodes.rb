class AddOriginalNodeIdToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :original_node_id, :integer
  end
end
