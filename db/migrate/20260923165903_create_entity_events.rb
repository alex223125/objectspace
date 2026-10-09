# db/migrate/20260923002000_create_entity_events.rb

class CreateEntityEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :entity_events do |t|
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   }

      # Optional reference to the version associated with this event.
      # For example, a "published" event can point to the version
      # that was published.
      t.bigint :entity_version_id

      # The user/account that performed the action.
      # We intentionally do not add a foreign key yet because the
      # application's user/account structure has not been confirmed.
      t.bigint :actor_id

      # Examples:
      # created
      # updated
      # published
      # archived
      # restored
      # deprecated
      # rollback
      #
      # Later workflow events can include:
      # submitted_for_review
      # approved
      # rejected
      # publish_scheduled
      # publish_schedule_cancelled
      t.string :event_type, null: false

      # Additional information about the event.
      #
      # Example:
      # {
      #   "previous_status": "draft",
      #   "new_status": "published"
      # }
      t.jsonb :metadata, null: false, default: {}

      # When the event actually happened.
      #
      # This is intentionally separate from created_at because the
      # event timestamp represents the lifecycle action itself.
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :entity_events, :entity_version_id
    add_index :entity_events, :actor_id

    add_index :entity_events,
              [:entity_id, :occurred_at]

    add_index :entity_events,
              [:entity_id, :event_type]
  end
end
