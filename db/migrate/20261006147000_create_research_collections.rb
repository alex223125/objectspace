class CreateResearchCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collections do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "active"
      t.string :color, null: false, default: "orange"
      t.boolean :pinned, null: false, default: false
      t.integer :position, null: false, default: 0
      t.datetime :last_opened_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :research_collections, :status
    add_index :research_collections, :pinned
    add_index :research_collections, :last_opened_at
  end
end
