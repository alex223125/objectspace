class CreateResearchCollectionEvidenceLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_evidence_links do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true,
                   index: { name: "idx_evidence_links_collection" }

      t.references :research_workspace,
                   null: false,
                   foreign_key: true,
                   index: { name: "idx_evidence_links_workspace" }

      t.string :evidence_type, null: false
      t.bigint :evidence_id, null: false
      t.text :note

      t.timestamps
    end

    add_index :research_collection_evidence_links,
              [:research_collection_id, :evidence_type, :evidence_id],
              unique: true,
              name: "idx_collection_evidence_unique"

    add_index :research_collection_evidence_links,
              [:evidence_type, :evidence_id],
              name: "idx_collection_evidence_reference"
  end
end
