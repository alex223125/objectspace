class AddReferencedStepFunctionalTypeToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :referenced_step_functional_type, :integer
  end
end
