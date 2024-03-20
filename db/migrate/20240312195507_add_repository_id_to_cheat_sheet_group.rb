class AddRepositoryIdToCheatSheetGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_groups, :repository_id, :integer
  end
end
