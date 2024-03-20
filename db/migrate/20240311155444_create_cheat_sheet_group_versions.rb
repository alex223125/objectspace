class CreateCheatSheetGroupVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :cheat_sheet_group_versions do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
