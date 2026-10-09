class CreateResearchAnnotations < ActiveRecord::Migration[7.0]
  def change
    create_table :research_annotations do |t|
      t.references :research_workspace,
                   null: false,
                   foreign_key: true

      t.references :research_workspace_item,
                   null: false,
                   foreign_key: true

      t.string :kind,
               null: false,
               default: "note"

      t.string :title,
               null: false

      t.text :body,
             null: false

      t.integer :confidence,
                null: false,
                default: 50

      t.string :status,
               null: false,
               default: "draft"

      t.string :author_name

      t.string :reviewer_name

      t.datetime :reviewed_at

      t.integer :position,
                null: false,
                default: 0

      t.timestamps
    end

    add_index :research_annotations,
              [:research_workspace_id, :position],
              name: "idx_research_annotations_workspace_position"

    add_index :research_annotations,
              [:research_workspace_item_id, :created_at],
              name: "idx_research_annotations_item_created"

    add_index :research_annotations,
              :status
  end
end