class AddTitleToReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :title, :string
  end
end
