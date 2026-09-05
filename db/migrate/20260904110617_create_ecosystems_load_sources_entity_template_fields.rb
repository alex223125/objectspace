class CreateEcosystemsLoadSourcesEntityTemplateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_template_fields do |t|
      t.bigint :entity_template_version_id, null: false

      t.string :name, null: false
      t.string :slug, null: false
      t.string :label, null: false
      t.text :description

      t.string :field_type, null: false

      t.boolean :required, default: false, null: false
      t.boolean :multiple, default: false, null: false

      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :ecosystems_load_sources_entity_template_fields,
              :entity_template_version_id,
              name: "idx_entity_template_fields_version"

    add_index :ecosystems_load_sources_entity_template_fields,
              [:entity_template_version_id, :slug],
              unique: true,
              name: "idx_entity_template_fields_version_slug"

    add_foreign_key :ecosystems_load_sources_entity_template_fields,
                    :ecosystems_load_sources_entity_template_versions,
                    column: :entity_template_version_id
  end
end