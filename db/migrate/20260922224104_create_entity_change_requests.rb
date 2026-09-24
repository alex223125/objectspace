# frozen_string_literal: true

class CreateEntityChangeRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_change_requests do |t|
      t.bigint :entity_id, null: false
      t.bigint :entity_version_id

      t.bigint :requested_by_id, null: false
      t.bigint :assigned_to_id

      t.text :reason, null: false

      t.string :status, null: false, default: "open"

      t.datetime :resolved_at
      t.bigint :resolved_by_id

      t.timestamps
    end

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :entity_id

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :entity_version_id

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :requested_by_id

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :assigned_to_id

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :resolved_by_id

    add_index \
      :ecosystems_load_sources_entity_change_requests,
      :status

    add_foreign_key \
      :ecosystems_load_sources_entity_change_requests,
      :ecosystems_load_sources_entities,
      column: :entity_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_change_requests,
      :ecosystems_load_sources_entity_versions,
      column: :entity_version_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_change_requests,
      :users,
      column: :requested_by_id,
      on_delete: :restrict

    add_foreign_key \
      :ecosystems_load_sources_entity_change_requests,
      :users,
      column: :assigned_to_id,
      on_delete: :nullify

    add_foreign_key \
      :ecosystems_load_sources_entity_change_requests,
      :users,
      column: :resolved_by_id,
      on_delete: :nullify
  end
end