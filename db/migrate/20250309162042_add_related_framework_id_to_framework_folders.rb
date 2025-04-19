class AddRelatedFrameworkIdToFrameworkFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :related_framework_id, :integer
  end
end
