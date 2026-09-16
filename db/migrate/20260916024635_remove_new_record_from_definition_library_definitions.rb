class RemoveNewRecordFromDefinitionLibraryDefinitions < ActiveRecord::Migration[7.0]
  def change
    table =
      :ecosystems_load_sources_entity_template_versions_definition_library_definitions

    remove_column table, :new_record, :boolean if column_exists?(table, :new_record)
  end
end