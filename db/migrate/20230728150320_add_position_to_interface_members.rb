class AddPositionToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_members, :position, :integer
  end
end
