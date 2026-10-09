class CreateResearchCollectionWorkspaceSignals < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_workspace_signals do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true,
                   index: { name: "idx_workspace_signals_collection" }

  t.references :research_workspace,
               null: true,
               foreign_key: true,
               index: { name: "idx_workspace_signals_workspace" }

  t.string :signal_type, null: false
  t.string :title, null: false
  t.text :statement, null: false
  t.string :confidence, null: false, default: "unknown"
  t.string :source_key
  t.json :metadata
  t.integer :position, null: false, default: 0

  t.timestamps
end

add_index :research_collection_workspace_signals,
          [:research_collection_id, :signal_type],
          name: "idx_collection_workspace_signals_type"

add_index :research_collection_workspace_signals,
          [:research_collection_id, :position],
          name: "idx_collection_workspace_signals_position"

    end
  end
