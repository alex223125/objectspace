class AddLoggingStepIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :logging_step_id, :integer
  end
end
