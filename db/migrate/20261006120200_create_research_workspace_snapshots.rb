class CreateResearchWorkspaceSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :research_workspace_snapshots do |t|
      t.references :research_workspace,
                   null: false,
                   foreign_key: true,
                   index: true

      t.string :name, null: false
      t.string :reason, null: false, default: "manual"
      t.text :description

      t.json :state, null: false, default: {}
      t.json :metadata, null: false, default: {}

      t.integer :item_count, null: false, default: 0
      t.integer :annotation_count, null: false, default: 0
      t.integer :evidence_count, null: false, default: 0
      t.integer :verified_evidence_count, null: false, default: 0
      t.integer :research_strength, null: false, default: 0

      t.string :kind, null: false, default: "manual"
      t.string :label, null: false
      t.text :data, null: false
      t.string :checksum, null: false

      t.timestamps
    end

    add_index :research_workspace_snapshots,
              [:research_workspace_id, :created_at],
              name: "index_workspace_snapshots_on_workspace_and_created_at"

    add_index :research_workspace_snapshots,
              [:research_workspace_id, :kind],
              name: "index_workspace_snapshots_on_workspace_and_kind"

    add_index :research_workspace_snapshots,
              :checksum
  end
end
