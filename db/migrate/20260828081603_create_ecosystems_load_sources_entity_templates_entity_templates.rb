class CreateEcosystemsLoadSourcesEntityTemplatesEntityTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_templates do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.bigint :entity_type_id, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :ecosystems_load_sources_entity_templates,
              :slug,
              unique: true,
              name: "idx_entity_templates_slug"

    add_index :ecosystems_load_sources_entity_templates,
              :entity_type_id,
              name: "idx_entity_templates_entity_type"

    add_foreign_key :ecosystems_load_sources_entity_templates,
                    :ecosystems_load_sources_entity_types,
                    column: :entity_type_id
  end
end
