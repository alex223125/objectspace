class AddOwnerableTypeAndOwnerableIdToReportsRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :reports_repositories, :ownerable_type, :string
    add_column :reports_repositories, :ownerable_id, :integer
  end
end