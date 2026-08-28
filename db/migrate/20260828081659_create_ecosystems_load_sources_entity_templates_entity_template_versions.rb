class CreateEcosystemsLoadSourcesEntityTemplatesEntityTemplateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_template_versions do |t|
      t.bigint :entity_template_id, null: false
      t.integer :version, null: false
      t.string :status, null: false, default: "draft"
      t.jsonb :definition, null: false, default: {}
      t.datetime :published_at

      t.timestamps
    end

    add_index :ecosystems_load_sources_entity_template_versions,
              [:entity_template_id, :version],
              unique: true,
              name: "idx_entity_template_versions_template_version"

    add_index :ecosystems_load_sources_entity_template_versions,
              :entity_template_id,
              name: "idx_entity_template_versions_template"

    add_foreign_key :ecosystems_load_sources_entity_template_versions,
                    :ecosystems_load_sources_entity_templates,
                    column: :entity_template_id
  end
end
