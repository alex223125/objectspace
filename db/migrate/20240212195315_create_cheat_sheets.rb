class CreateCheatSheets < ActiveRecord::Migration[7.0]
  def change
    create_table :cheat_sheets do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
