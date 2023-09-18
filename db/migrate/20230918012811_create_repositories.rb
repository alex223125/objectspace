class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :name
      t.text :description
      t.boolean :is_private

      t.timestamps
    end
  end
end
