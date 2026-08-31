class CreateEcosystemsLoadSourcesEntityTemplateConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_template_configurations do |t|
      t.references :entity_template,
                   null: false,
                   index: {
                     name: "idx_et_config_template"
                   },
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_templates,
                     name: "fk_et_config_template"
                   }

      t.references :entity_type,
                   null: false,
                   index: {
                     name: "idx_et_config_type"
                   },
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_types,
                     name: "fk_et_config_type"
                   }

      t.references :context,
                   polymorphic: true,
                   null: false,
                   index: {
                     name: "idx_et_config_context"
                   }

      t.boolean :enabled,
                null: false,
                default: true

      t.integer :position,
                null: false,
                default: 0

      t.jsonb :settings,
              null: false,
              default: {}

      t.timestamps
    end

    add_index :ecosystems_load_sources_entity_template_configurations,
              [:context_type, :context_id, :entity_type_id],
              unique: true,
              name: "idx_et_config_context_type"
  end
end