class AddPositionToSubsteps < ActiveRecord::Migration[7.0]
  def change
    add_column :substeps, :position, :integer
  end
end
