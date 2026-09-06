class AddIndexesToEntityTemplateVersions < ActiveRecord::Migration[7.0]
  def change
    add_index(
      :ecosystems_load_sources_entity_template_versions,
      :status,
      name: "idx_entity_template_versions_status"
    )

    add_index(
      :ecosystems_load_sources_entity_template_versions,
      :created_at,
      name: "idx_entity_template_versions_created_at"
    )

    add_index(
      :ecosystems_load_sources_entity_template_versions,
      :updated_at,
      name: "idx_entity_template_versions_updated_at"
    )

    add_index(
      :ecosystems_load_sources_entity_template_versions,
      [:status, :version],
      name: "idx_entity_template_versions_status_version"
    )
  end
end
