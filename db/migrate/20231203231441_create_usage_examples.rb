class CreateUsageExamples < ActiveRecord::Migration[7.0]
  def change
    create_table :usage_examples do |t|
      t.string :title
      t.text :content
      t.text :sources

      t.timestamps
    end
  end
end