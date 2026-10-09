
class CreateResearchCollectionSnapshots < ActiveRecord::Migration[7.0]
  def up
    unless table_exists?(:research_collection_snapshots)
      create_table :research_collection_snapshots do |t|
        t.references :research_collection,
                     null: false,
                     foreign_key: true,
                     index: {
                       name: "idx_collection_snapshots_collection"
                     }

        t.integer :version_number, null: false
        t.string :snapshot_type, null: false, default: "full"
        t.string :status, null: false, default: "completed"

        t.json :payload, null: false, default: {}
        t.json :metadata

        t.text :summary
        t.datetime :captured_at

        t.timestamps
      end
    end

    if table_exists?(:research_collection_snapshots)
      add_index :research_collection_snapshots,
                [:research_collection_id, :version_number],
                unique: true,
                name: "idx_collection_snapshots_version",
                if_not_exists: true
    end
  end

  def down
    drop_table :research_collection_snapshots if table_exists?(:research_collection_snapshots)
  end
end