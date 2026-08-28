class CreateEcosystemsLoadSourcesActorsActors < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystems_load_sources_actors_actors do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
    add_index :ecosystems_load_sources_actors_actors, :slug, unique: true
  end
end