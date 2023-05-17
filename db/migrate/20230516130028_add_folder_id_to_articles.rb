class AddFolderIdToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :folder_id, :integer
  end
end
