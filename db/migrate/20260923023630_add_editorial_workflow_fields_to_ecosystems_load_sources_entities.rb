# frozen_string_literal: true

class AddEditorialWorkflowFieldsToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]

  def change
    add_reference(
      :ecosystems_load_sources_entities,
      :reviewer,
      foreign_key: {
        to_table: :users
      },
      index: true
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :submitted_by,
      foreign_key: {
        to_table: :users
      },
      index: true
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :approved_by,
      foreign_key: {
        to_table: :users
      },
      index: true
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :rejected_by,
      foreign_key: {
        to_table: :users
      },
      index: true
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :reviewer_assigned_by,
      foreign_key: {
        to_table: :users
      },
      index: true
    )

    add_column(
      :ecosystems_load_sources_entities,
      :reviewer_assigned_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :review_comment,
      :text
    )

    add_column(
      :ecosystems_load_sources_entities,
      :rejection_reason,
      :text
    )

    add_column(
      :ecosystems_load_sources_entities,
      :submitted_for_review_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :approved_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :rejected_at,
      :datetime
    )
  end

end