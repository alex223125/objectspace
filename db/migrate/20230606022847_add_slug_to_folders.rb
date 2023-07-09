class AddSlugToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :slug, :string
    add_index :folders, :slug, unique: true
  end
end
