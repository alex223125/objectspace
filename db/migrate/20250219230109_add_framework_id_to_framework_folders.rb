class AddFrameworkIdToFrameworkFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :framework_id, :integer
  end
end
