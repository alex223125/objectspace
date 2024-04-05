class AddCreatorIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :creator_id, :integer
  end
end
