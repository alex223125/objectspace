class CreateResearchWorkspaceEvidences < ActiveRecord::Migration[7.0]
  def change
    create_table :research_workspace_evidences do |t|
      t.references :research_workspace_item,
                   foreign_key: true,
                   index: { name: "idx_rwe_item" }

      t.references :research_workspace_annotation,
                   foreign_key: true,
                   index: { name: "idx_rwe_annotation" }

      t.string :title, null: false

      t.string :evidence_type,
               null: false,
               default: "source"

      t.string :source_name
      t.string :source_url

      t.text :excerpt
      t.text :notes

      t.datetime :published_at
      t.datetime :accessed_at

      t.integer :confidence,
                null: false,
                default: 50

      t.boolean :verified,
                null: false,
                default: false

      t.string :verification_note

      t.integer :position,
                null: false,
                default: 0

      t.timestamps
    end

    add_index :research_workspace_evidences,
              [:research_workspace_item_id, :position],
              name: "idx_research_evidence_item_position"

    add_index :research_workspace_evidences,
              :evidence_type

    add_index :research_workspace_evidences,
              :verified

    add_index :research_workspace_evidences,
              :confidence
  end
end