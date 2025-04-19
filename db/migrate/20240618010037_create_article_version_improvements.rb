class CreateArticleVersionImprovements < ActiveRecord::Migration[7.0]
  def change
    create_table :article_version_improvements do |t|
      t.references :article_version, null: false, foreign_key: true
      t.references :improvement, null: false, foreign_key: true

      t.timestamps
    end
  end
end