class AddAlgorithmVersionIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :algorithm_version_id, :integer
  end
end
