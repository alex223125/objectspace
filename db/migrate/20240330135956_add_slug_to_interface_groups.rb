class AddSlugToInterfaceGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_groups, :slug, :string
    add_index :interface_groups, :slug, unique: true
  end
end
