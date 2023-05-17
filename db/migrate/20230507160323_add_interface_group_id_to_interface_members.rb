class AddInterfaceGroupIdToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_members, :interface_group_id, :integer
  end
end
