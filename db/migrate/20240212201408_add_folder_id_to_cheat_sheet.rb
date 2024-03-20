class AddFolderIdToCheatSheet < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :folder_id, :integer
  end
end
