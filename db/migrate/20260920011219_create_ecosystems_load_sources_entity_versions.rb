class CreateEcosystemsLoadSourcesEntityVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_versions do |t|
      t.references(
        :entity,
        null: false,
        foreign_key: {
          to_table: :ecosystems_load_sources_entities
        },
        index: true
      )

      t.integer :version_number, null: false

      t.string :status, null: false

      t.string :reason

      t.jsonb :snapshot, null: false, default: {}

      t.string :checksum

      t.datetime :published_at

      t.references(
        :created_by,
        polymorphic: true,
        null: true,
        index: true
      )

      t.timestamps null: false
    end

    add_index(
      :ecosystems_load_sources_entity_versions,
      [
        :entity_id,
        :version_number
      ],
      unique: true,
      name: "idx_entity_versions_entity_and_number"
    )

    add_index(
      :ecosystems_load_sources_entity_versions,
      :checksum
    )

    add_index(
      :ecosystems_load_sources_entity_versions,
      :published_at
    )
  end
end