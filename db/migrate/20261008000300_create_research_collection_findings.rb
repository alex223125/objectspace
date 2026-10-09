class CreateResearchCollectionFindings < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_findings do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.string :title, null: false
      t.text :body, null: false

      t.string :status, null: false, default: "draft"
      t.string :confidence, null: false, default: "medium"
      t.text :statement, null: false

      t.boolean :contradiction, null: false, default: false

      t.integer :position, null: false, default: 0

      t.datetime :published_at

      t.timestamps
    end

    add_index :research_collection_findings,
              [:research_collection_id, :position],
              name: "idx_collection_findings_position"

    add_index :research_collection_findings,
              [:research_collection_id, :status],
              name: "idx_collection_findings_status"

    add_index :research_collection_findings,
              [:research_collection_id, :contradiction],
              name: "idx_collection_findings_contradiction"
  end
end