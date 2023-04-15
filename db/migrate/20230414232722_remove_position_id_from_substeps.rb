class RemovePositionIdFromSubsteps < ActiveRecord::Migration[7.0]
  def change
    remove_column :substeps, :position_id, :integer
  end
end
