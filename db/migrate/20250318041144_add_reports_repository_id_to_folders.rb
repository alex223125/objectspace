class AddReportsRepositoryIdToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :reports_repository_id, :integer
  end
end
