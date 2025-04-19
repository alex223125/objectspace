class AddIsPrivateToReportsRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :is_private, :boolean
  end
end
