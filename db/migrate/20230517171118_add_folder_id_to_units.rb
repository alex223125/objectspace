class AddFolderIdToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :folder_id, :integer
  end
end
