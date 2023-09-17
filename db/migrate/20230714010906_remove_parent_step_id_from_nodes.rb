class RemoveParentStepIdFromNodes < ActiveRecord::Migration[7.0]
  def change
    remove_column :nodes, :parent_step_id, :integer
  end
end
