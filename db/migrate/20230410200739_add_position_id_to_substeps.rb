class AddPositionIdToSubsteps < ActiveRecord::Migration[7.0]
  def change
    add_column :substeps, :position_id, :integer
  end
end
