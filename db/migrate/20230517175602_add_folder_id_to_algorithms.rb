class AddFolderIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :folder_id, :integer
  end
end