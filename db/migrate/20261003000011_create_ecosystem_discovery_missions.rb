# frozen_string_literal: true

class CreateEcosystemDiscoveryMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystem_discovery_missions do |t|
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   },
                   index: true

      t.string :mission_type, null: false
      t.string :title, null: false
      t.text :description

      t.integer :xp_reward, null: false, default: 10
      t.integer :progress, null: false, default: 0
      t.integer :target, null: false, default: 1

      t.string :state, null: false, default: "available"

      t.jsonb :metadata, null: false, default: {}

      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :ecosystem_discovery_missions,
              [:entity_id, :mission_type],
              unique: true,
              name: "idx_discovery_missions_entity_type"
  end
end
