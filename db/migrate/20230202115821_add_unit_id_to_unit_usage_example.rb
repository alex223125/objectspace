class AddUnitIdToUnitUsageExample < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_usage_examples, :unit_id, :integer
  end
end
