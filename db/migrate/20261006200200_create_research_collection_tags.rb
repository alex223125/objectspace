class CreateResearchCollectionTags < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_tags do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.string :name,
               null: false

      t.string :color,
               null: false,
               default: "slate"

      t.timestamps
    end

    add_index :research_collection_tags,
              [:research_collection_id, :name],
              unique: true,
              name: "idx_collection_tags_unique_name"

    add_index :research_collection_tags,
              :name
  end
end