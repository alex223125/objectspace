class AlignResearchWorkspaceEvidences < ActiveRecord::Migration[7.0]
  def up
    table = :research_workspace_evidences

add_column table,
           :evidence_type,
           :string,
           null: false,
           default: "source" unless column_exists?(table, :evidence_type)

add_column table,
           :position,
           :integer,
           null: false,
           default: 0 unless column_exists?(table, :position)

add_column table,
           :confidence,
           :integer,
           null: false,
           default: 50 unless column_exists?(table, :confidence)

add_column table,
           :verified,
           :boolean,
           null: false,
           default: false unless column_exists?(table, :verified)

add_column table,
           :verified_at,
           :datetime unless column_exists?(table, :verified_at)

if column_exists?(table, :kind)
  execute <<~SQL
    UPDATE research_workspace_evidences
    SET evidence_type =
      CASE
        WHEN kind IN (
          'source',
          'document',
          'dataset',
          'publication',
          'interview',
          'observation',
          'internal_note',
          'other'
        )
        THEN kind
        ELSE 'source'
      END
    WHERE evidence_type IS NULL OR evidence_type = ''
  SQL
else
  execute <<~SQL
    UPDATE research_workspace_evidences
    SET evidence_type = 'source'
    WHERE evidence_type IS NULL OR evidence_type = ''
  SQL
end

if column_exists?(table, :confidence_score)
  execute <<~SQL
    UPDATE research_workspace_evidences
    SET confidence = COALESCE(confidence_score, 50)
    WHERE confidence IS NULL
  SQL
end

if column_exists?(table, :verification_status)
  execute <<~SQL
    UPDATE research_workspace_evidences
    SET verified =
      CASE
        WHEN verification_status IN ('verified', 'confirmed', 'approved')
        THEN TRUE
        ELSE FALSE
      END
  SQL
end

add_index table,
          [:research_workspace_item_id, :position],
          name: "idx_ws_evidences_item_pos",
          if_not_exists: true if column_exists?(table, :research_workspace_item_id)

add_index table,
          :evidence_type,
          name: "idx_ws_evidences_type",
          if_not_exists: true

add_index table,
          :confidence,
          name: "idx_ws_evidences_confidence",
          if_not_exists: true

add_index table,
          :verified,
          name: "idx_ws_evidences_verified",
          if_not_exists: true

  end

  def down
    table = :research_workspace_evidences

remove_index table, name: "idx_ws_evidences_item_pos", if_exists: true
remove_index table, name: "idx_ws_evidences_type", if_exists: true
remove_index table, name: "idx_ws_evidences_confidence", if_exists: true
remove_index table, name: "idx_ws_evidences_verified", if_exists: true

remove_column table, :verified_at if column_exists?(table, :verified_at)
remove_column table, :verified if column_exists?(table, :verified)
remove_column table, :confidence if column_exists?(table, :confidence)
remove_column table, :position if column_exists?(table, :position)
remove_column table, :evidence_type if column_exists?(table, :evidence_type)

  end
end
