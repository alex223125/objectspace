class CreateEcosystemExplorerProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystem_explorer_profiles do |t|
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table: :ecosystems_load_sources_entities
                   },
                   index: { unique: true }

      t.jsonb :metadata, null: false, default: {}

      t.integer :xp, null: false, default: 0
      t.integer :level, null: false, default: 1

      t.integer :discoveries_count, null: false, default: 0
      t.integer :comparisons_count, null: false, default: 0
      t.integer :investigations_count, null: false, default: 0

      t.integer :current_streak, null: false, default: 0
      t.integer :longest_streak, null: false, default: 0

      t.datetime :last_activity_at

      t.timestamps
    end
  end
end