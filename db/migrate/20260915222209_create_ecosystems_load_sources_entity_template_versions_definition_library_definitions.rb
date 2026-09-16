class CreateEcosystemsLoadSourcesEntityTemplateVersionsDefinitionLibraryDefinitions < ActiveRecord::Migration[7.0]
  TABLE_NAME = :ecosystems_load_sources_entity_template_versions_definition_library_definitions

  def change
    create_table TABLE_NAME do |t|
      # Stable catalog identifier.
      t.string :key, null: false

      # Display information.
      t.string :name, null: false
      t.string :category, null: false
      t.text :description

      # UI metadata.
      t.jsonb :tags, null: false, default: []
      t.string :icon

      # Commercial ranking metadata.
      t.integer :popularity, null: false, default: 0
      t.boolean :featured, null: false, default: false
      t.boolean :new_record, null: false, default: false

      # Definition version.
      t.integer :version, null: false, default: 1

      # Definition field structure.
      t.jsonb :fields, null: false, default: []

      # Library availability.
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index TABLE_NAME,
              :key,
              unique: true,
              name: :eld_key_uq

    add_index TABLE_NAME,
              :category,
              name: :eld_category_idx

    add_index TABLE_NAME,
              :featured,
              name: :eld_featured_idx

    add_index TABLE_NAME,
              :popularity,
              name: :eld_popularity_idx

    add_index TABLE_NAME,
              :active,
              name: :eld_active_idx
  end
end