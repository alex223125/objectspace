class AddCreatorIdToCheatSheetGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_groups, :creator_id, :integer
  end
end
