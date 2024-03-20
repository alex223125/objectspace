class AddOwnerableTypeAndOwnerableIdToCheatSheetGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheet_groups, :ownerable_type, :string
    add_column :cheat_sheet_groups, :ownerable_id, :integer
  end
end
