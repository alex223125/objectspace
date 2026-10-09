# frozen_string_literal: true

class CreateEcosystemsLoadSourcesEntityRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_relationships do |t|

      t.references :source_entity,
                   null: false,
                   index: { name: "idx_esr_source_entity" },
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   }

      t.references :target_entity,
                   null: false,
                   index: { name: "idx_esr_target_entity" },
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   }

      t.string :relationship_kind,
               null: false,
               default: "related"

      t.decimal :confidence,
                precision: 5,
                scale: 4,
                null: false,
                default: 0.0

      t.string :state,
               null: false,
               default: "suggested"

      t.jsonb :evidence,
              null: false,
              default: []

      t.datetime :last_discovered_at

      t.timestamps
    end

    add_index(
      :ecosystems_load_sources_entity_relationships,
      [:source_entity_id, :target_entity_id],
      unique: true,
      name: "idx_entity_relationships_source_target"
    )

    add_index(
      :ecosystems_load_sources_entity_relationships,
      [:target_entity_id, :source_entity_id],
      name: "idx_entity_relationships_target_source"
    )

    add_index(
      :ecosystems_load_sources_entity_relationships,
      :relationship_kind,
      name: "idx_entity_relationships_kind"
    )

    add_index(
      :ecosystems_load_sources_entity_relationships,
      :state,
      name: "idx_entity_relationships_state"
    )

    add_index(
      :ecosystems_load_sources_entity_relationships,
      :confidence,
      name: "idx_entity_relationships_confidence"
    )
  end
end