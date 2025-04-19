class AddSlugToFrameworkFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :slug, :string
    add_index :framework_folders, :slug, unique: true
  end
end