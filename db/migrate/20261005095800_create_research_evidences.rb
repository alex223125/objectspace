class CreateResearchEvidences < ActiveRecord::Migration[7.0]
  def change
    create_table :research_evidences do |t|
      t.references :research_workspace,
                   null: false,
                   foreign_key: true

      t.references :research_workspace_item,
                   null: false,
                   foreign_key: true

      t.references :research_annotation,
                   null: true,
                   foreign_key: true

      t.string :title, null: false
      t.string :source_type, null: false, default: "web"
      t.string :source_url
      t.string :publisher
      t.string :author
      t.date :published_on
      t.date :accessed_on
      t.text :excerpt
      t.text :notes
      t.integer :confidence, null: false, default: 50
      t.boolean :verified, null: false, default: false
      t.datetime :verified_at
      t.string :external_id

      t.timestamps
    end

    add_index :research_evidences,
              [:research_workspace_id, :created_at],
              name: "idx_research_evidences_workspace_created"

    add_index :research_evidences,
              [:research_workspace_item_id, :created_at],
              name: "idx_research_evidences_item_created"

    # research_annotation_id already has an index
    # because t.references creates one by default.

    add_index :research_evidences, :source_type
  end
end
