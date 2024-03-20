class AddFolderIdToCheatSheetGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_groups, :folder_id, :integer
  end
end
