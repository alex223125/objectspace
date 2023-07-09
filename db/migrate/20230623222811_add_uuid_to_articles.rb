class AddUuidToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
