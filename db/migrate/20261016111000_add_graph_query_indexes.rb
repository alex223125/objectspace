# frozen_string_literal: true

class AddGraphQueryIndexes < ActiveRecord::Migration[7.0]
  def change
    return unless table_exists?(:entity_relationships)

    add_index :entity_relationships,
              :source_entity_id,
              if_not_exists: true,
              name: "idx_entity_relationships_source"

    add_index :entity_relationships,
              :target_entity_id,
              if_not_exists: true,
              name: "idx_entity_relationships_target"

    add_index :entity_relationships,
              :state,
              if_not_exists: true,
              name: "idx_entity_relationships_state"

    add_index :entity_relationships,
              [:source_entity_id, :state],
              if_not_exists: true,
              name: "idx_entity_relationships_source_state"

    add_index :entity_relationships,
              [:target_entity_id, :state],
              if_not_exists: true,
              name: "idx_entity_relationships_target_state"
  end
end