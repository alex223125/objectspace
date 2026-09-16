# frozen_string_literal: true

class CreateEcosystemsLoadSourcesEntityTemplateVersionsDefinitionTemplates < ActiveRecord::Migration[7.0]
  TABLE_NAME = :ecosystems_load_sources_entity_template_versions_definition_templates

  def change
    create_table TABLE_NAME do |t|
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :category, null: false

      t.text :description

      t.string :icon
      t.string :color

      t.boolean :featured, null: false, default: false
      t.boolean :active, null: false, default: true
      t.boolean :is_new, null: false, default: false

      t.integer :popularity_score, null: false, default: 0
      t.integer :usage_count, null: false, default: 0

      t.string :status, null: false, default: "published"

      t.jsonb :tags, null: false, default: []
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    # Short explicit index names are required because the full Rails-generated
    # names exceed PostgreSQL's 63-character identifier limit.

    add_index TABLE_NAME,
              :external_id,
              unique: true,
              name: "idx_def_templates_ext_id"

    add_index TABLE_NAME,
              :slug,
              unique: true,
              name: "idx_def_templates_slug"

    add_index TABLE_NAME,
              :category,
              name: "idx_def_templates_category"

    add_index TABLE_NAME,
              :active,
              name: "idx_def_templates_active"

    add_index TABLE_NAME,
              :featured,
              name: "idx_def_templates_featured"

    add_index TABLE_NAME,
              :is_new,
              name: "idx_def_templates_is_new"

    add_index TABLE_NAME,
              :popularity_score,
              name: "idx_def_templates_popularity"

    add_index TABLE_NAME,
              :status,
              name: "idx_def_templates_status"
  end
end