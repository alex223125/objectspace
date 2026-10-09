class AddLifecycleFieldsToEntities < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:ecosystems_load_sources_entities, :published_at)
      add_column :ecosystems_load_sources_entities, :published_at, :datetime
    end

    unless column_exists?(:ecosystems_load_sources_entities, :archived_at)
      add_column :ecosystems_load_sources_entities, :archived_at, :datetime
    end
  end
end