
# db/migrate/20261015201000_create_relationship_audit_events.rb

class CreateRelationshipAuditEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_relationship_audit_events do |t|
      t.bigint :relationship_id
      t.bigint :source_entity_id
      t.bigint :target_entity_id
      t.bigint :actor_id

      t.string :action, null: false
      t.string :before_state
      t.string :after_state

      t.jsonb :details, null: false, default: {}

      t.timestamps
    end

    add_index(
      :ecosystems_load_sources_entity_relationship_audit_events,
      :relationship_id,
      name: "idx_graph_audit_relationship"
    )

    add_index(
      :ecosystems_load_sources_entity_relationship_audit_events,
      :actor_id,
      name: "idx_graph_audit_actor"
    )

    add_index(
      :ecosystems_load_sources_entity_relationship_audit_events,
      :created_at,
      name: "idx_graph_audit_created_at"
    )

    add_index(
      :ecosystems_load_sources_entity_relationship_audit_events,
      [:source_entity_id, :target_entity_id],
      name: "idx_graph_audit_endpoints"
    )
  end
end