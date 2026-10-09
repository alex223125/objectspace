class AddSavedInvestigationHistory < ActiveRecord::Migration[7.0]
  def change
    # Add history timestamps to existing research workspaces.
    change_table :research_workspaces, bulk: true do |t|
      t.datetime :saved_at
      t.datetime :last_resumed_at
      t.datetime :completed_at
      t.datetime :archived_at
      t.datetime :last_snapshot_at
    end

    # The research_workspace_snapshots table already exists.
    # Do not recreate it or add existing columns such as description.
    change_table :research_workspace_snapshots, bulk: true do |t|
      t.integer :sequence, null: false, default: 0
      t.string :event_type, null: false, default: "manual"
      t.string :title
      t.json :payload, null: false, default: {}
      t.string :created_by_name
    end

    add_index :research_workspace_snapshots,
              [:research_workspace_id, :sequence],
              unique: true,
              name: "idx_workspace_snapshots_workspace_sequence"

    add_index :research_workspace_snapshots,
              [:research_workspace_id, :created_at],
              name: "idx_workspace_snapshots_workspace_created"
  end
end
