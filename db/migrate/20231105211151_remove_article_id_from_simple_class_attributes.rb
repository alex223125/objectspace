class RemoveArticleIdFromSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    remove_column :simple_class_attributes, :article_id, :integer
  end
end
