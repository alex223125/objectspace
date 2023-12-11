class AddIsForAllVersionsToUsageExamples < ActiveRecord::Migration[7.0]
  def change
    add_column :usage_examples, :is_for_all_versions, :boolean, default: false
  end
end
