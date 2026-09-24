# frozen_string_literal: true

class CreateEntityEditorialComments < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_editorial_comments do |t|
      t.bigint :entity_id, null: false
      t.bigint :entity_version_id
      t.bigint :user_id, null: false

      t.text :body, null: false

      t.datetime :resolved_at
      t.bigint :resolved_by_id

      t.timestamps
    end

    add_index \
      :ecosystems_load_sources_entity_editorial_comments,
      :entity_id

    add_index \
      :ecosystems_load_sources_entity_editorial_comments,
      :entity_version_id

    add_index \
      :ecosystems_load_sources_entity_editorial_comments,
      :user_id

    add_index \
      :ecosystems_load_sources_entity_editorial_comments,
      :resolved_by_id

    add_foreign_key \
      :ecosystems_load_sources_entity_editorial_comments,
      :ecosystems_load_sources_entities,
      column: :entity_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_editorial_comments,
      :ecosystems_load_sources_entity_versions,
      column: :entity_version_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_editorial_comments,
      :users,
      column: :user_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_editorial_comments,
      :users,
      column: :resolved_by_id,
      on_delete: :nullify
  end
end
