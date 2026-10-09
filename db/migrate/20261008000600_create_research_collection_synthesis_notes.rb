class CreateResearchCollectionSynthesisNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_synthesis_notes do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true,
                   index: {
                     name: "idx_synthesis_notes_collection"
                   }

      t.string :title, null: false
      t.text :content, null: false
      t.text :body, null: false

      t.string :status, null: false, default: "draft"

      t.string :note_type, null: false, default: "synthesis"
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :research_collection_synthesis_notes,
              [:research_collection_id, :status],
              name: "idx_collection_synthesis_notes_status"
  end
end
