class CreateResearchWorkspaceAnnotations < ActiveRecord::Migration[7.0]
  def change
    create_table :research_workspace_annotations do |t|
      t.references :research_workspace_item, null: false, foreign_key: true, index: { name: "idx_ws_annotations_item" }

      t.string :title, null: false
      t.text :body, null: false

      t.string :kind, null: false, default: "expert_note"
      t.string :author_name

      t.integer :confidence, null: false, default: 50
      t.string :status, null: false, default: "draft"

      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :research_workspace_annotations,
              [:research_workspace_item_id, :position],
              name: "idx_research_annotations_item_position"

    add_index :research_workspace_annotations,
              :status

    add_index :research_workspace_annotations,
              :kind
  end
end