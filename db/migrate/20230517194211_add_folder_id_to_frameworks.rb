class AddFolderIdToFrameworks < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks, :folder_id, :integer
  end
end
