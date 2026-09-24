class AddEditorialWorkflowToEcosystemsEntities < ActiveRecord::Migration[7.0]
  def change
    add_reference(
      :ecosystems_load_sources_entities,
      :reviewer,
      foreign_key: {
        to_table: :users
      },
      null: true
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :reviewer_assigned_by,
      foreign_key: {
        to_table: :users
      },
      null: true
    )

    add_column(
      :ecosystems_load_sources_entities,
      :reviewer_assigned_at,
      :datetime
    )

    add_column(
      :ecosystems_load_sources_entities,
      :change_requested_at,
      :datetime
    )

    add_reference(
      :ecosystems_load_sources_entities,
      :change_requested_by,
      foreign_key: {
        to_table: :users
      },
      null: true
    )

    add_column(
      :ecosystems_load_sources_entities,
      :change_request_reason,
      :text
    )

    add_index(
      :ecosystems_load_sources_entities,
      :workflow_state
    )

    add_index(
      :ecosystems_load_sources_entities,
      :reviewer_id
    )

    create_table :ecosystems_load_sources_entity_editorial_comments do |t|
      t.references :entity,
                   null: false,
                   foreign_key: {
                     to_table:
                       :ecosystems_load_sources_entities
                   }

      t.references :author,
                   null: false,
                   foreign_key: {
                     to_table: :users
                   }

      t.string :comment_type,
                 null: false,
                 default: "comment"

      t.text :body,
              null: false

      t.references :entity_version,
                   null: true,
                   foreign_key: {
                     to_table:
                       :ecosystems_load_sources_entity_versions
                   }

      t.timestamps
    end

    add_index(
      :ecosystems_load_sources_entity_editorial_comments,
      [
        :entity_id,
        :created_at
      ]
    )

    add_index(
      :ecosystems_load_sources_entity_editorial_comments,
      :comment_type
    )
  end
end
