class CreateResearchCollectionEvidenceReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_evidence_references do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true,
                   index: {
                     name: "idx_coll_evidence_refs_collection"
                   }

      t.references :research_workspace,
                   foreign_key: true,
                   index: {
                     name: "idx_coll_evidence_refs_workspace"
                   }

      t.string :name, null: false

      t.string :source_type
      t.string :title, null: false
      t.text :description
      t.text :source_url
      t.string :external_identifier
      t.integer :confidence, null: false, default: 0

      t.timestamps
    end

    add_index :research_collection_evidence_references,
              :source_type,
              name: "idx_evidence_refs_source_type"

    add_index :research_collection_evidence_references,
              :external_identifier,
              name: "idx_evidence_refs_external_id"
  end
end
