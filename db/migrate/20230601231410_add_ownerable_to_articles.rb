class AddOwnerableToArticles < ActiveRecord::Migration[7.0]
  def change
    add_reference :articles, :ownerable, polymorphic: true, null: false, index: true
  end
end
