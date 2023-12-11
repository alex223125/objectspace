class CreateUnitVersionUsageExamples < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_version_usage_examples do |t|
      t.references :unit_version, null: false, foreign_key: true
      t.references :usage_example, null: false, foreign_key: true

      t.timestamps
    end
  end
end
