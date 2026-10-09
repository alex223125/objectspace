class CreateResearchWorkspaces < ActiveRecord::Migration[7.0]
  def change
    create_table :research_workspaces do |t|
      t.string :title, null: false
      t.string :slug, null: false

      # Optional polymorphic ownership.
      # This allows the workspace to work with User, AdminUser,
      # Account, etc. without hard-coding your authentication model.
      t.string :owner_type
      t.bigint :owner_id

      # Anonymous/session ownership fallback.
      t.string :visitor_key

      t.string :status, null: false, default: "active"
      t.text :summary

      # JSON-compatible serialized metadata.
      t.text :metadata

      t.datetime :last_opened_at

      t.timestamps
    end

    add_index :research_workspaces,
              :slug,
              unique: true

    add_index :research_workspaces,
              [:owner_type, :owner_id]

    add_index :research_workspaces,
              :visitor_key

    add_index :research_workspaces,
              :status
  end
end