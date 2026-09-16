class CreateEcosystemsLoadSourcesEntityTemplateVersionsDefinitionTemplateUsages < ActiveRecord::Migration[7.0]
  TABLE_NAME = :ecosystems_load_sources_entity_template_versions_definition_template_usages
  PG_TABLE_NAME = :entity_template_usages

  def change
    create_table PG_TABLE_NAME do |t|
      t.references :definition_template,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_template_versions_definition_templates,
                     name: :fk_entity_template_usages_definition_template
                   }

      t.references :definition_template_version,
                   null: true,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_template_definition_versions,
                     name: :fk_entity_template_usages_definition_template_version
                   }

      t.references :user,
                   null: true,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_entity_template_usages_user
                   }

      t.string :event_type, null: false
      t.string :source
      t.string :session_id

      t.jsonb :metadata,
              null: false,
              default: {}

      t.datetime :created_at, null: false
    end

    add_index PG_TABLE_NAME,
              :event_type,
              name: :idx_entity_template_usages_event_type

    add_index PG_TABLE_NAME,
              :created_at,
              name: :idx_entity_template_usages_created_at

    add_index PG_TABLE_NAME,
              :source,
              name: :idx_entity_template_usages_source

    add_index PG_TABLE_NAME,
              :session_id,
              name: :idx_entity_template_usages_session
  end
end