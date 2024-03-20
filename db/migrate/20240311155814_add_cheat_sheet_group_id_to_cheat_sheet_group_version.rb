class AddCheatSheetGroupIdToCheatSheetGroupVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_group_versions, :cheat_sheet_group_id, :integer
  end
end
