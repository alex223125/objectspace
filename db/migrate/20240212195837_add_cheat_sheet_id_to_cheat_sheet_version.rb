class AddCheatSheetIdToCheatSheetVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_versions, :cheat_sheet_id, :integer
  end
end
