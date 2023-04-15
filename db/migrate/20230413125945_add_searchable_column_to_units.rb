class AddSearchableColumnToUnits < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TABLE units
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(source_page_description,'')), 'B')
      ) STORED;
    SQL
  end

  def down
    remove_column :units, :searchable
  end
end