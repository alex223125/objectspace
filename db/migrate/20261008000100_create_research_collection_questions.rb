class CreateResearchCollectionQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_questions do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.string :question, null: false
      t.string :status, null: false, default: "open"
      t.string :priority, null: false, default: "normal"
      t.integer :position, null: false, default: 0
      t.text :context
      t.text :resolution
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :research_collection_questions,
              [:research_collection_id, :position],
              name: "idx_collection_questions_position"

    add_index :research_collection_questions,
              [:research_collection_id, :status],
              name: "idx_collection_questions_status"
  end
end
