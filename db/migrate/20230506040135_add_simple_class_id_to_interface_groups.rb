class AddSimpleClassIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :simple_class_id, :integer
  end
end
