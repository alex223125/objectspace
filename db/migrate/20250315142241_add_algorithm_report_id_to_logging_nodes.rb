class AddAlgorithmReportIdToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :algorithm_report_id, :integer
  end
end
