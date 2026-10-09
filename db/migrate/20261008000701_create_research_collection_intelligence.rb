class CreateResearchCollectionIntelligence < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_snapshots do |t|
      t.references :research_collection, null: false, foreign_key: true

      t.string :label, null: false
      t.text :payload, null: false

      t.string :reason
      t.integer :version_number, null: false

      t.timestamps
    end

    add_index :research_collection_snapshots,
              [:research_collection_id, :version_number],
              unique: true,
              name: "idx_collection_snapshots_version"
  end
end