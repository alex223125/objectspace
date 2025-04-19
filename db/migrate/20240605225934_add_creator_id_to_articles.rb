class AddCreatorIdToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :creator_id, :integer
  end
end
