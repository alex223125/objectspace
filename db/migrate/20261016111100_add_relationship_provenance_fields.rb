# frozen_string_literal: true

class AddRelationshipProvenanceFields < ActiveRecord::Migration[7.0]
  def change
    table = :entity_relationships
    return unless table_exists?(table)

    unless column_exists?(table, :discovery_method)
      add_column table, :discovery_method, :string
    end

    unless column_exists?(table, :provenance)
      add_column table, :provenance, :jsonb,
                 null: false, default: {}
    end

    unless column_exists?(table, :reviewed_at)
      add_column table, :reviewed_at, :datetime
    end

    unless column_exists?(table, :reviewed_by_id)
      add_column table, :reviewed_by_id, :bigint
    end
  end
end