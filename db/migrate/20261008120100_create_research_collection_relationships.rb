
class CreateResearchCollectionRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_relationships do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true,
                   index: { name: "idx_collection_relationships_collection" }

      t.references :source_workspace,
                   null: false,
                   foreign_key: { to_table: :research_workspaces },
                   index: { name: "idx_collection_relationships_source" }

      t.references :target_workspace,
                   null: false,
                   foreign_key: { to_table: :research_workspaces },
                   index: { name: "idx_collection_relationships_target" }

      t.string :relationship_type, null: false
      t.string :confidence, null: false, default: "medium"
      t.string :status, null: false, default: "active"
      t.text :note
      t.json :metadata
      t.string :label
      t.text :description
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :research_collection_relationships,
              [:research_collection_id, :relationship_type],
              name: "idx_collection_relationships_type"

    add_index :research_collection_relationships,
              [:source_workspace_id, :target_workspace_id],
              unique: true,
              name: "idx_collection_relationships_workspaces"
  end
end