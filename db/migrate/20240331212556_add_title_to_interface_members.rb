class AddTitleToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_members, :title, :string
  end
end
