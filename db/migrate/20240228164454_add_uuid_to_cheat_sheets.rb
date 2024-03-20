class AddUuidToCheatSheets < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
