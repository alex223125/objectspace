class CreateArticlesSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :articles_simple_class_attributes do |t|
      t.references :article, null: false, foreign_key: {to_table: :articles}, index: true,
                   index: { name: 'index_articles_attributes_on_article_id' }
      t.references :simple_class_attribute, null: false, foreign_key: {to_table: :simple_class_attributes}, index: true,
                   index: { name: 'index_articles_attributes_on_simple_class_attribute_id' }

      t.timestamps
    end
  end
end
