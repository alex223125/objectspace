class AddFunctionalTypeToFrameworkFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :functional_type, :integer
  end
end
