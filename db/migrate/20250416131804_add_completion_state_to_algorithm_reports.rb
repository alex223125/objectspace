class AddCompletionStateToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :completion_state, :integer
  end
end
