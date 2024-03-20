class CreateCheatSheetGroupSections < ActiveRecord::Migration[7.0]
  def change
    create_table :cheat_sheet_group_sections do |t|
      t.references :sectionable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
