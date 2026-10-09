# frozen_string_literal: true

class CreateEntityChangeRequests < ActiveRecord::Migration[7.0]
  TABLE_NAME = :ecosystems_load_sources_entity_change_requests

  def change
    create_table TABLE_NAME do |t|
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

    # Indexes: explicitly named to avoid PostgreSQL's
    # 63-character identifier limit.

    add_index TABLE_NAME,
              :entity_id,
              name: "idx_change_requests_entity_id"

    add_index TABLE_NAME,
              :entity_version_id,
              name: "idx_change_requests_version_id"

    add_index TABLE_NAME,
              :requested_by_id,
              name: "idx_change_requests_requested_by"

    add_index TABLE_NAME,
              :assigned_to_id,
              name: "idx_change_requests_assigned_to"

    add_index TABLE_NAME,
              :resolved_by_id,
              name: "idx_change_requests_resolved_by"

    add_index TABLE_NAME,
              :status,
              name: "idx_change_requests_status"

    # Foreign keys

    add_foreign_key TABLE_NAME,
                    :ecosystems_load_sources_entities,
                    column: :entity_id,
                    on_delete: :restrict

    add_foreign_key TABLE_NAME,
                    :ecosystems_load_sources_entity_versions,
                    column: :entity_version_id,
                    on_delete: :restrict

    add_foreign_key TABLE_NAME,
                    :users,
                    column: :requested_by_id,
                    on_delete: :restrict

    add_foreign_key TABLE_NAME,
                    :users,
                    column: :assigned_to_id,
                    on_delete: :nullify

    add_foreign_key TABLE_NAME,
                    :users,
                    column: :resolved_by_id,
                    on_delete: :nullify
  end
end
