class AddSlugToCheatSheetGroupVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_group_versions, :slug, :string
    add_index :cheat_sheet_group_versions, :slug, unique: true
  end
end
