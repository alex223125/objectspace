class AddSearchableColumnToUnitVersions < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE unit_versions
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(instruction,'')), 'B') ||
        setweight(to_tsvector('english', coalesce(solves_the_problem, '')), 'C') ||
        setweight(to_tsvector('english', coalesce(sources, '')), 'D')
      ) STORED;
    SQL
  end

  def down
    remove_column :unit_versions, :searchable
  end
end