class AddCheatSheetGroupVersionIdToCheatSheetGroupSection < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_group_sections, :cheat_sheet_group_version_id, :integer
  end
end
