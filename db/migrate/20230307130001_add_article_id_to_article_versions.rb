class AddArticleIdToArticleVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :article_versions, :article_id, :integer
  end
end
