class AddFrameworkFolderIdToFrameworkMember < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_members, :framework_folder_id, :integer
  end
end
