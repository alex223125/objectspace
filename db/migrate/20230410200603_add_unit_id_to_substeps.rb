class AddUnitIdToSubsteps < ActiveRecord::Migration[7.0]
  def change
    add_column :substeps, :unit_id, :integer
  end
end
