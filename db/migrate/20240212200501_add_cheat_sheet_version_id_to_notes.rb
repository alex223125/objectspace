class AddCheatSheetVersionIdToNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :cheat_sheet_version_id, :integer
  end
end
