class AddControlStructureIdToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :control_structure_id, :integer
  end
end
