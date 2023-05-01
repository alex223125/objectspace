class AddSearchableColumnToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE algorithm_versions
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(solves_the_problem,'')), 'B') ||
        setweight(to_tsvector('english', coalesce(sources,'')), 'C') ||
        setweight(to_tsvector('english', coalesce(additional_information,'')), 'D')
      ) STORED;
    SQL
  end

  def down
    remove_column :algorithm_versions, :searchable
  end
end
