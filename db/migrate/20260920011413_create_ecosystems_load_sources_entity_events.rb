# frozen_string_literal: true

class CreateEcosystemsLoadSourcesEntityEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_events do |t|
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   },
                   index: {
                     name: "idx_entity_events_entity"
                   }

      t.references :entity_version,
                   null: true,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entity_versions
                   },
                   index: {
                     name: "idx_entity_events_version"
                   }

      # Lifecycle/action information
      t.string :event_type, null: false
      t.string :from_status
      t.string :to_status

      # Who/what caused the event
      t.string :actor_type
      t.bigint :actor_id

      # Human-readable explanation
      t.string :message

      # Flexible event metadata
      t.jsonb :metadata, null: false, default: {}

      # Snapshot of relevant entity data at the time of the event.
      # This gives us a durable audit trail even if the entity changes later.
      t.jsonb :snapshot, null: false, default: {}

      t.datetime :created_at, null: false
    end

    add_index :ecosystems_load_sources_entity_events,
              :event_type,
              name: "idx_entity_events_type"

    add_index :ecosystems_load_sources_entity_events,
              [:entity_id, :created_at],
              name: "idx_entity_events_entity_time"

    add_index :ecosystems_load_sources_entity_events,
              [:entity_id, :event_type],
              name: "idx_entity_events_entity_type"

    add_index :ecosystems_load_sources_entity_events,
              :actor_id,
              name: "idx_entity_events_actor"

    add_index :ecosystems_load_sources_entity_events,
              :created_at,
              name: "idx_entity_events_created_at"
  end
end
