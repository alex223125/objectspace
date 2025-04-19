class AddDescriptionToReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :description, :text
  end
end
