class AlignResearchWorkspaceAnnotations < ActiveRecord::Migration[7.0]
  TABLE = :research_workspace_annotations

  POSITION_INDEX = "idx_ws_annotations_item_position"
  STATUS_INDEX = "idx_ws_annotations_status"
  CONFIDENCE_INDEX = "idx_ws_annotations_confidence"

  def up
    add_column TABLE, :title, :string,
               null: false, default: "Annotation" unless column_exists?(TABLE, :title)

    add_column TABLE, :confidence, :integer,
               null: false, default: 50 unless column_exists?(TABLE, :confidence)

    add_column TABLE, :status, :string,
               null: false, default: "draft" unless column_exists?(TABLE, :status)

    add_column TABLE, :position, :integer,
               null: false, default: 0 unless column_exists?(TABLE, :position)

    if column_exists?(TABLE, :kind)
      execute <<~SQL
        UPDATE research_workspace_annotations
        SET title = COALESCE(NULLIF(kind, ''), 'Annotation')
        WHERE title IS NULL OR title = ''
      SQL
    end

    if column_exists?(TABLE, :confidence_score)
      execute <<~SQL
        UPDATE research_workspace_annotations
        SET confidence = COALESCE(confidence_score, 50)
        WHERE confidence IS NULL
      SQL
    end

    if column_exists?(TABLE, :review_status)
      execute <<~SQL
        UPDATE research_workspace_annotations
        SET status = COALESCE(NULLIF(review_status, ''), 'draft')
        WHERE status IS NULL OR status = ''
      SQL
    end

    add_index TABLE,
              [:research_workspace_item_id, :position],
              name: POSITION_INDEX,
              if_not_exists: true

    add_index TABLE,
              :status,
              name: STATUS_INDEX,
              if_not_exists: true

    add_index TABLE,
              :confidence,
              name: CONFIDENCE_INDEX,
              if_not_exists: true
  end

  def down
    remove_index TABLE,
                 name: POSITION_INDEX,
                 if_exists: true

    remove_index TABLE,
                 name: STATUS_INDEX,
                 if_exists: true

    remove_index TABLE,
                 name: CONFIDENCE_INDEX,
                 if_exists: true

    remove_column TABLE, :position if column_exists?(TABLE, :position)
    remove_column TABLE, :status if column_exists?(TABLE, :status)
    remove_column TABLE, :confidence if column_exists?(TABLE, :confidence)
    remove_column TABLE, :title if column_exists?(TABLE, :title)
  end
end
