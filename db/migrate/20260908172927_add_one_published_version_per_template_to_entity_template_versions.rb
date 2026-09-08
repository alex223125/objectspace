class AddOnePublishedVersionPerTemplateToEntityTemplateVersions < ActiveRecord::Migration[7.0]
  TABLE_NAME = :ecosystems_load_sources_entity_template_versions
  INDEX_NAME = "idx_one_published_version_per_template"

  def up
    # Keep only the highest published version for each template.
    execute <<~SQL
      UPDATE #{TABLE_NAME}
      SET status = 'draft'
      WHERE id IN (
        SELECT id
        FROM (
          SELECT
            id,
            ROW_NUMBER() OVER (
              PARTITION BY entity_template_id
              ORDER BY version DESC, id DESC
            ) AS row_number
          FROM #{TABLE_NAME}
          WHERE status = 'published'
        ) published_versions
        WHERE row_number > 1
      )
    SQL

    add_index TABLE_NAME,
              :entity_template_id,
              unique: true,
              where: "status = 'published'",
              name: INDEX_NAME
  end

  def down
    remove_index TABLE_NAME, name: INDEX_NAME
  end
end
