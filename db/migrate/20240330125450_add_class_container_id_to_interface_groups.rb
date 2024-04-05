class AddClassContainerIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :class_container_id, :integer
  end
end
