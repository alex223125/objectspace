class RemoveUnitIdFromImprovements < ActiveRecord::Migration[7.0]
  def change
    remove_column :improvements, :unit_id, :integer
  end
end
