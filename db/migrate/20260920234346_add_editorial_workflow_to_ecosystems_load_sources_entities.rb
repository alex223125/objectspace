# frozen_string_literal: true

class AddEditorialWorkflowToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  def change
    change_table :ecosystems_load_sources_entities, bulk: true do |t|
      # ----------------------------------------------------------
      # Editorial workflow
      # ----------------------------------------------------------

      t.string :workflow_state,
               null: false,
               default: "draft"

      t.datetime :submitted_for_review_at
      t.datetime :approved_at
      t.datetime :rejected_at

      t.bigint :submitted_by_id
      t.bigint :approved_by_id
      t.bigint :rejected_by_id

      t.text :review_comment
      t.text :rejection_reason

      # ----------------------------------------------------------
      # Scheduled publishing
      # ----------------------------------------------------------

      t.datetime :publish_at

      # Actor responsible for the actual publication.
      t.bigint :published_by_id

      # ----------------------------------------------------------
      # Workflow indexes
      # ----------------------------------------------------------

      t.index :workflow_state,
              name: "idx_entities_workflow_state"

      t.index :publish_at,
              name: "idx_entities_publish_at"

      t.index [:workflow_state, :publish_at],
              name: "idx_entities_workflow_publish"

      t.index :submitted_by_id,
              name: "idx_entities_submitted_by"

      t.index :approved_by_id,
              name: "idx_entities_approved_by"

      t.index :rejected_by_id,
              name: "idx_entities_rejected_by"

      t.index :published_by_id,
              name: "idx_entities_published_by"
    end
  end
end
