class CreateMissingEntityTemplateVersions < ActiveRecord::Migration[7.0]
  def up
    template_table =
      :ecosystems_load_sources_entity_templates

    version_table =
      :ecosystems_load_sources_entity_template_versions

    entity_table =
      :ecosystems_load_sources_entities

    # ---------------------------------------------------------
    # STEP 1
    # Create v1 for every template that has no versions.
    # ---------------------------------------------------------

    execute <<~SQL
      INSERT INTO #{version_table}
        (
          entity_template_id,
          version,
          status,
          definition,
          created_at,
          updated_at
        )
      SELECT
        t.id,
        1,
        'draft',
        '{}'::jsonb,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
      FROM #{template_table} t
      WHERE NOT EXISTS (
        SELECT 1
        FROM #{version_table} v
        WHERE v.entity_template_id = t.id
      );
    SQL

    # ---------------------------------------------------------
    # STEP 2
    # Attach every entity without a version to the latest
    # version of its current template.
    # ---------------------------------------------------------

    execute <<~SQL
      UPDATE #{entity_table} e
      SET entity_template_version_id = latest.version_id
      FROM (
        SELECT DISTINCT ON (entity_template_id)
          entity_template_id,
          id AS version_id
        FROM #{version_table}
        ORDER BY
          entity_template_id,
          version DESC
      ) latest
      WHERE e.entity_template_id = latest.entity_template_id
        AND e.entity_template_version_id IS NULL;
    SQL
  end

  def down
    # We intentionally do not delete the generated versions
    # or detach entities during rollback.
    #
    # This protects existing entity/template data.
  end
end
