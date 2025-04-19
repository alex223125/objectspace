class AddFolderIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :folder_id, :integer
  end
end
