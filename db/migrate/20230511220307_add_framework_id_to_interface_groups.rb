class AddFrameworkIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :framework_id, :integer
  end
end
