class AddOwnerableTypeAndOwnerableIdToCheatSheets < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :ownerable_type, :string
    add_column :cheat_sheets, :ownerable_id, :integer
  end
end
