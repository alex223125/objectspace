class AddAlgorithmReportIdToLoggingIntroductionSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_introduction_steps, :algorithm_report_id, :integer
  end
end
