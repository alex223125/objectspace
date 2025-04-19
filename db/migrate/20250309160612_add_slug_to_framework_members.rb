class AddSlugToFrameworkMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_members, :slug, :string
    add_index :framework_members, :slug, unique: true
  end
end
