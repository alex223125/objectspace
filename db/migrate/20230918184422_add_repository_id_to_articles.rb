class AddRepositoryIdToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :repository_id, :integer
  end
end
