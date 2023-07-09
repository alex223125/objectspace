class AddSlugToArticleVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :article_versions, :slug, :string
    add_index :article_versions, :slug, unique: true
  end
end
