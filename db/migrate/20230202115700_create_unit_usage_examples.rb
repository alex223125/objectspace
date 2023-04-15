class CreateUnitUsageExamples < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_usage_examples do |t|
      t.string :title
      t.text :description
      t.text :sources

      t.timestamps
    end
  end
end
