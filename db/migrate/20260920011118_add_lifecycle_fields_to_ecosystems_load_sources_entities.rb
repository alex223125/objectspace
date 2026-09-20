# frozen_string_literal: true

class AddLifecycleFieldsToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :ecosystems_load_sources_entities,
      :published_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :archived_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :deprecated_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :current_version_id,
      :bigint
    )

    add_index(
      :ecosystems_load_sources_entities,
      :published_at
    )

    add_index(
      :ecosystems_load_sources_entities,
      :archived_at
    )

    add_index(
      :ecosystems_load_sources_entities,
      :deprecated_at
    )

    add_index(
      :ecosystems_load_sources_entities,
      :current_version_id
    )
  end
end
