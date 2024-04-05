class AddTitleToContainerMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :container_members, :title, :string
  end
end
