# frozen_string_literal: true

class UpgradeEntityRelationshipEvidence < ActiveRecord::Migration[7.0]
  def change
    change_column(
      :ecosystems_load_sources_entity_relationships,
      :evidence,
      :jsonb,
      null: false,
      default: []
    )

    add_index(
      :ecosystems_load_sources_entity_relationships,
      :evidence,
      using: :gin,
      name: "idx_entity_relationships_evidence"
    )
  end
end