class AddReportsRepositoryIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reports_repository_id, :integer
  end
end
