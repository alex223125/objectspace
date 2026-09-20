class AddCurrentVersionForeignKeyToEntities < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key(
      :ecosystems_load_sources_entities,
      :ecosystems_load_sources_entity_versions,
      column: :current_version_id
    )
  end
end
