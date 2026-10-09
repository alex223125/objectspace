class CreateResearchCollectionMilestones < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_milestones do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.integer :position, null: false, default: 0
      t.datetime :due_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :research_collection_milestones,
              [:research_collection_id, :position],
              name: "idx_collection_milestones_position"

    add_index :research_collection_milestones,
              [:research_collection_id, :status],
              name: "idx_collection_milestones_status"
  end
end
