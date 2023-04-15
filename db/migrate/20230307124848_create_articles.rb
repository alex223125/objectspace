class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.integer :default_version_id
      t.integer :visibility_status
      t.text :source_page_description

      t.timestamps
    end
  end
end
