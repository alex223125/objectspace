class AddParentIdToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :parent_id, :integer
  end
end
