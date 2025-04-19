class AddReportsRepositoryIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :reports_repository_id, :integer
  end
end
