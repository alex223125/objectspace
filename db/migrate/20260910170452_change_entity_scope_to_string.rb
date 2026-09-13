class ChangeEntityScopeToString < ActiveRecord::Migration[7.0]
  def up
    change_column_default :ecosystems_load_sources_entities,
                          :scope,
                          from: 0,
                          to: "conceptual"

    change_column :ecosystems_load_sources_entities,
                  :scope,
                  :string,
                  using: <<~SQL.squish
                    CASE scope
                    WHEN 0 THEN 'conceptual'
                    WHEN 1 THEN 'real_world'
                    WHEN 2 THEN 'hybrid'
                    ELSE 'conceptual'
                    END
                  SQL
  end

  def down
    change_column :ecosystems_load_sources_entities,
                  :scope,
                  :integer,
                  using: <<~SQL.squish
                    CASE scope
                    WHEN 'conceptual' THEN 0
                    WHEN 'real_world' THEN 1
                    WHEN 'hybrid' THEN 2
                    ELSE 0
                    END
                  SQL

    change_column_default :ecosystems_load_sources_entities,
                          :scope,
                          from: "conceptual",
                          to: 0
  end
end
