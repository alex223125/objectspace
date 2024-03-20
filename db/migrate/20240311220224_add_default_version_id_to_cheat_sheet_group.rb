class AddDefaultVersionIdToCheatSheetGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_groups, :default_version_id, :integer
  end
end
