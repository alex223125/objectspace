class AddPositionToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :position, :integer
  end
end
