class CreateUsageExamples < ActiveRecord::Migration[7.0]
  def change
    create_table :usage_examples do |t|
      t.string :title
      t.text :description
      t.text :sources

      t.references :usage_exampable, polymorphic: true, null: false

      t.timestamps
    end
  end
end