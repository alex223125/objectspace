class CreateEcosystemsLoadSourcesEntityTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_entity_types do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      t.bigint :parent_id

      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :ecosystems_load_sources_entity_types, :slug, unique: true

    add_index :ecosystems_load_sources_entity_types, :parent_id

    add_foreign_key(
      :ecosystems_load_sources_entity_types,
      :ecosystems_load_sources_entity_types,
      column: :parent_id
    )
  end
end
