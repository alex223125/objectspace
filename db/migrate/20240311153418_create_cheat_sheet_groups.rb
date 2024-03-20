class CreateCheatSheetGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :cheat_sheet_groups do |t|
      t.string :title
      t.text :source_page_description

      t.timestamps
    end
  end
end
