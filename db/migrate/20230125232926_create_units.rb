class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.string :title
      t.text :instruction

      t.timestamps
    end
  end
end
