
class CreateEntityVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :entity_versions do |t|
      # References ecosystems_load_sources_entities, not entities.
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   }

      t.integer :version_number, null: false

      # Immutable JSONB snapshot of entity content.
      t.jsonb :snapshot, null: false, default: {}

      # User who created this version.
      t.bigint :created_by_id

      t.timestamps
    end

    add_index :entity_versions,
              [:entity_id, :version_number],
              unique: true

    add_index :entity_versions, :created_by_id
  end
end