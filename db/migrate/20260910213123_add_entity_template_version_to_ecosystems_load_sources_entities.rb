class AddEntityTemplateVersionToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  def change
    add_reference :ecosystems_load_sources_entities,
                  :entity_template_version,
                  null: true,
                  index: {
                    name: "idx_entities_template_version"
                  },
                  foreign_key: {
                    to_table: :ecosystems_load_sources_entity_template_versions
                  }
  end
end
