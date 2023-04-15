class AddSearchableColumnToImprovements < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE improvements
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(content,'')), 'B') ||
        setweight(to_tsvector('english', coalesce(sources,'')), 'C')
      ) STORED;
    SQL
  end

  def down
    remove_column :improvements, :searchable
  end
end