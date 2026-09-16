# frozen_string_literal: true

class CreateEcosystemsLoadSourcesEntityTemplateVersionsDefinitionTemplateVersions < ActiveRecord::Migration[7.0]
  TABLE_NAME = "ecosystems_load_sources_entity_template_definition_versions"
  DEFINITION_TEMPLATES_TABLE =
    "ecosystems_load_sources_entity_template_versions_definition_templates"

  def change
    create_table TABLE_NAME do |t|
      t.bigint :definition_template_id, null: false

      t.integer :version, null: false

      t.string :status,
               null: false,
               default: "draft"

      t.text :change_summary

      t.jsonb :definition,
              null: false,
              default: {}

      t.jsonb :metadata,
              null: false,
              default: {}

      t.datetime :published_at
      t.datetime :deprecated_at

      t.timestamps
    end

    add_foreign_key TABLE_NAME,
                    DEFINITION_TEMPLATES_TABLE,
                    column: :definition_template_id

    add_index TABLE_NAME,
              [:definition_template_id, :version],
              unique: true,
              name: "idx_def_template_versions_unique"

    add_index TABLE_NAME,
              :status,
              name: "idx_def_template_versions_status"

    add_index TABLE_NAME,
              :published_at,
              name: "idx_def_template_versions_published"

    add_index TABLE_NAME,
              :definition_template_id,
              name: "idx_def_template_versions_template"
  end
end