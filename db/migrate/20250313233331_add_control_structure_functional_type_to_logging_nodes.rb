class AddControlStructureFunctionalTypeToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :control_structure_functional_type, :integer
  end
end
