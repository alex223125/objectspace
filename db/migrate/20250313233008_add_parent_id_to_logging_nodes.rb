class AddParentIdToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :parent_id, :integer
  end
end
