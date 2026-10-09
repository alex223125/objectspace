class CreateResearchCollectionObjectives < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_objectives do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.integer :progress, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.datetime :completed_at

      t.timestamps
    end

    add_index :research_collection_objectives,
              [:research_collection_id, :position],
              name: "idx_collection_objectives_position"

    add_index :research_collection_objectives,
              [:research_collection_id, :status],
              name: "idx_collection_objectives_status"


  end
end