class AddSlugToReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :slug, :string
    add_index :reports_repositories, :slug, unique: true
  end
end
