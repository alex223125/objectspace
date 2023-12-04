class DropUnitUsageExamples < ActiveRecord::Migration[7.0]
  def up
    drop_table :unit_usage_examples
  end

  def down
    create_table :unit_usage_examples do |t|
      t.string :title
      t.text :description
      t.text :sources
      t.integer :unit_id
      t.boolean :is_for_all_unit_versions

      t.timestamps
    end
  end
end