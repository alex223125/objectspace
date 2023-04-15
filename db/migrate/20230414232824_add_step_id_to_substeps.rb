class AddStepIdToSubsteps < ActiveRecord::Migration[7.0]
  def change
    add_column :substeps, :step_id, :integer
  end
end
