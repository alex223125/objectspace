class AddIsForAllUnitVersionsToUnitUsageExamples < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_usage_examples, :is_for_all_unit_versions, :boolean
  end
end
