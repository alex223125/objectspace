class CreateImprovements < ActiveRecord::Migration[7.0]
  def change
    create_table :improvements do |t|
      t.string :title
      t.text :content
      t.text :sources

      t.timestamps
    end
  end
end
