class CreateEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entities do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.references :entity_type,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_types
                   }

      t.references :entity_template,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_templates
                   }

      t.string :status, null: false, default: "draft"

      t.integer :scope,
                null: false,
                default: 0

      t.text :summary
      t.jsonb :metadata, null: false, default: {}

      t.datetime :valid_from
      t.datetime :valid_until
      t.datetime :observed_at

      t.timestamps
    end

    add_index :ecosystems_load_sources_entities,
              :slug,
              unique: true
  end
end
