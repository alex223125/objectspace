class AddRelatedSimpleClassIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :related_simple_class_id, :integer
  end
end
