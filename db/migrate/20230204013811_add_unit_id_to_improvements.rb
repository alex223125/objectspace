class AddUnitIdToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_column :improvements, :unit_id, :integer
  end
end
