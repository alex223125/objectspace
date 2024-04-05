class AddSlugToContainerMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :container_members, :slug, :string
    add_index :container_members, :slug, unique: true
  end
end
