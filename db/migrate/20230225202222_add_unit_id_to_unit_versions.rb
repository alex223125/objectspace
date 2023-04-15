class AddUnitIdToUnitVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_versions, :unit_id, :integer
  end
end
