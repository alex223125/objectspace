# frozen_string_literal: true

class AddDefinitionLibraryFields < ActiveRecord::Migration[7.0]
  TABLE =
    :ecosystems_load_sources_entity_template_versions_definition_library_definitions

  def change
    add_column TABLE, :slug, :string unless column_exists?(TABLE, :slug)
    add_column TABLE, :description, :text unless column_exists?(TABLE, :description)
    add_column TABLE, :category, :string unless column_exists?(TABLE, :category)
    add_column TABLE, :icon, :string unless column_exists?(TABLE, :icon)

    unless column_exists?(TABLE, :tags)
      add_column TABLE, :tags, :jsonb, default: [], null: false
    end

    unless column_exists?(TABLE, :definition_json)
      add_column TABLE, :definition_json, :jsonb, default: {}, null: false
    end

    add_column TABLE, :version, :string unless column_exists?(TABLE, :version)

    # IMPORTANT:
    # Do NOT create a column called `new_record`.
    #
    # ActiveRecord already defines:
    #   new_record?
    #
    # A database attribute called `new_record` causes:
    #   ActiveRecord::DangerousAttributeError
    #
    # If the application needs this concept later, use a name such as
    # `is_new` instead.

    add_column TABLE, :created_at, :datetime unless column_exists?(TABLE, :created_at)
    add_column TABLE, :updated_at, :datetime unless column_exists?(TABLE, :updated_at)

    # PostgreSQL limits identifier/index names to 63 characters.
    # The automatic Rails index name for this table is too long,
    # therefore explicit short names are required.

    unless index_exists?(TABLE, :slug)
      add_index TABLE,
                :slug,
                unique: true,
                name: "idx_def_library_slug"
    end

    unless index_exists?(TABLE, :category)
      add_index TABLE,
                :category,
                name: "idx_def_library_category"
    end

    unless index_exists?(TABLE, :active)
      add_index TABLE,
                :active,
                name: "idx_def_library_active"
    end
  end
end
