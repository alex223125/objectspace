# frozen_string_literal: true

class AddEditorialWorkflowToEcosystemsEntities < ActiveRecord::Migration[7.0]
  ENTITIES_TABLE = :ecosystems_load_sources_entities
  COMMENTS_TABLE = :ecosystems_load_sources_entity_editorial_comments

  def up
    add_reference(
      ENTITIES_TABLE,
      :reviewer,
      null: true,
      index: { name: "idx_ecosys_entities_reviewer" },
      foreign_key: { to_table: :users }
    ) unless column_exists?(ENTITIES_TABLE, :reviewer_id)

    add_reference(
      ENTITIES_TABLE,
      :reviewer_assigned_by,
      null: true,
      index: { name: "idx_ecosys_entities_reviewer_by" },
      foreign_key: { to_table: :users }
    ) unless column_exists?(ENTITIES_TABLE, :reviewer_assigned_by_id)

    add_column(
      ENTITIES_TABLE,
      :reviewer_assigned_at,
      :datetime
    ) unless column_exists?(ENTITIES_TABLE, :reviewer_assigned_at)

    add_column(
      ENTITIES_TABLE,
      :change_requested_at,
      :datetime
    ) unless column_exists?(ENTITIES_TABLE, :change_requested_at)

    add_reference(
      ENTITIES_TABLE,
      :change_requested_by,
      null: true,
      index: { name: "idx_ecosys_entities_change_by" },
      foreign_key: { to_table: :users }
    ) unless column_exists?(ENTITIES_TABLE, :change_requested_by_id)

    add_column(
      ENTITIES_TABLE,
      :change_request_reason,
      :text
    ) unless column_exists?(ENTITIES_TABLE, :change_request_reason)

    add_index(
      ENTITIES_TABLE,
      :workflow_state,
      name: "idx_ecosys_entities_workflow"
    ) if column_exists?(ENTITIES_TABLE, :workflow_state) &&
         !index_exists?(ENTITIES_TABLE, :workflow_state, name: "idx_ecosys_entities_workflow")

    add_index(
      ENTITIES_TABLE,
      :reviewer_id,
      name: "idx_ecosys_entities_reviewer_lookup"
    ) if column_exists?(ENTITIES_TABLE, :reviewer_id) &&
         !index_exists?(ENTITIES_TABLE, :reviewer_id, name: "idx_ecosys_entities_reviewer_lookup")

    create_comments_table unless table_exists?(COMMENTS_TABLE)

    add_index(
      COMMENTS_TABLE,
      %i[entity_id created_at],
      name: "idx_ecosys_comments_entity_created"
    ) if table_exists?(COMMENTS_TABLE) &&
         !index_exists?(COMMENTS_TABLE, %i[entity_id created_at], name: "idx_ecosys_comments_entity_created")

    # Ensure comment_type column exists before creating its index
    unless column_exists?(
      :ecosystems_load_sources_entity_editorial_comments,
      :comment_type
    )
      add_column :ecosystems_load_sources_entity_editorial_comments,
                 :comment_type,
                 :string,
                 null: false,
                 default: "general"
    end

    # Create the index if it does not already exist
    unless index_exists?(
      :ecosystems_load_sources_entity_editorial_comments,
      :comment_type,
      name: "idx_ecosys_comments_type"
    )
      add_index :ecosystems_load_sources_entity_editorial_comments,
                :comment_type,
                name: "idx_ecosys_comments_type"
    end
  end

  def down
    drop_table COMMENTS_TABLE if table_exists?(COMMENTS_TABLE)

    remove_column ENTITIES_TABLE, :change_request_reason if column_exists?(ENTITIES_TABLE, :change_request_reason)
    remove_reference ENTITIES_TABLE, :change_requested_by if column_exists?(ENTITIES_TABLE, :change_requested_by_id)
    remove_column ENTITIES_TABLE, :change_requested_at if column_exists?(ENTITIES_TABLE, :change_requested_at)
    remove_column ENTITIES_TABLE, :reviewer_assigned_at if column_exists?(ENTITIES_TABLE, :reviewer_assigned_at)
    remove_reference ENTITIES_TABLE, :reviewer_assigned_by if column_exists?(ENTITIES_TABLE, :reviewer_assigned_by_id)
    remove_reference ENTITIES_TABLE, :reviewer if column_exists?(ENTITIES_TABLE, :reviewer_id)

    remove_index ENTITIES_TABLE, name: "idx_ecosys_entities_workflow" if index_exists?(ENTITIES_TABLE, name: "idx_ecosys_entities_workflow")
    remove_index ENTITIES_TABLE, name: "idx_ecosys_entities_reviewer_lookup" if index_exists?(ENTITIES_TABLE, name: "idx_ecosys_entities_reviewer_lookup")
  end

  private

  def create_comments_table
    create_table COMMENTS_TABLE do |t|
      t.references(
        :entity,
        null: false,
        index: { name: "idx_ecosys_comments_entity" },
        foreign_key: { to_table: ENTITIES_TABLE }
      )

      t.references(
        :author,
        null: false,
        index: { name: "idx_ecosys_comments_author" },
        foreign_key: { to_table: :users }
      )

      t.string :comment_type, null: false, default: "comment"
      t.text :body, null: false

      t.references(
        :entity_version,
        null: true,
        index: { name: "idx_ecosys_comments_version" },
        foreign_key: { to_table: :ecosystems_load_sources_entity_versions }
      )

      t.timestamps
    end
  end
end
