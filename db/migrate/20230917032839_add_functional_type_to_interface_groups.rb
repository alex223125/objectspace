class AddFunctionalTypeToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :functional_type, :integer, null: false
  end
end
