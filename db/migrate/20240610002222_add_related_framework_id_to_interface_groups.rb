class AddRelatedFrameworkIdToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :related_framework_id, :integer
  end
end
