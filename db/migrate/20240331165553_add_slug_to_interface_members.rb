class AddSlugToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_members, :slug, :string
    add_index :interface_members, :slug, unique: true
  end
end