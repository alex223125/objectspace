class AddParentIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :parent_id, :integer
  end
end
