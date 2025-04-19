class AddFunctionalTypeToReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :functional_type, :integer
  end
end
