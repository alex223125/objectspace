class CreateResearchWorkspaceItems < ActiveRecord::Migration[7.0]
  def change
    create_table :research_workspace_items do |t|
      t.references :research_workspace,
                   null: false,
                   foreign_key: true

      t.string :kind, null: false
      t.string :title, null: false
      t.text :body

      # Optional polymorphic reference to application records.
      t.string :target_type
      t.bigint :target_id

      t.integer :position, null: false, default: 0
      t.string :status, null: false, default: "open"
      t.datetime :completed_at
      t.text :metadata

      t.timestamps
    end

    add_index :research_workspace_items,
              [:target_type, :target_id],
              name: "idx_workspace_items_target"

    add_index :research_workspace_items,
              [:research_workspace_id, :position],
              name: "idx_workspace_items_position"

    add_index :research_workspace_items,
              [:research_workspace_id, :kind],
              name: "idx_workspace_items_kind"
  end
end
