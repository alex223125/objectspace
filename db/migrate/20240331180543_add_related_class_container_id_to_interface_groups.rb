class AddRelatedClassContainerIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :related_class_container_id, :integer
  end
end
