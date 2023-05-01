class AddSearchableColumnToAlgorithms < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE algorithms
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(source_page_description,'')), 'B')
      ) STORED;
    SQL
  end

  def down
    remove_column :algorithms, :searchable
  end
end