class AddStepFunctionalTypeToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :step_functional_type, :integer
  end
end
