class AddParentIdToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :parent_id, :integer
  end
end
