class AddAlgorithmVersionIdToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :algorithm_version_id, :integer
  end
end
