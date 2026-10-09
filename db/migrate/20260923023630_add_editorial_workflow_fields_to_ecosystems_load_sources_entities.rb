
# frozen_string_literal: true

class AddEditorialWorkflowFieldsToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  TABLE = :ecosystems_load_sources_entities

  def up
    add_user_reference(:reviewer)
    add_user_reference(:submitted_by)
    add_user_reference(:approved_by)
    add_user_reference(:rejected_by)
    add_user_reference(:reviewer_assigned_by)

    add_column_unless_exists(:reviewer_assigned_at, :datetime)
    add_column_unless_exists(:review_comment, :text)
    add_column_unless_exists(:rejection_reason, :text)
    add_column_unless_exists(:submitted_for_review_at, :datetime)
    add_column_unless_exists(:approved_at, :datetime)
    add_column_unless_exists(:rejected_at, :datetime)
  end

  def down
    remove_column_if_exists(:rejected_at)
    remove_column_if_exists(:approved_at)
    remove_column_if_exists(:submitted_for_review_at)
    remove_column_if_exists(:rejection_reason)
    remove_column_if_exists(:review_comment)
    remove_column_if_exists(:reviewer_assigned_at)

    remove_user_reference(:reviewer_assigned_by)
    remove_user_reference(:rejected_by)
    remove_user_reference(:approved_by)
    remove_user_reference(:submitted_by)
    remove_user_reference(:reviewer)
  end

  private

  def add_user_reference(name)
    column = "#{name}_id"

    unless column_exists?(TABLE, column)
      add_reference(
        TABLE,
        name,
        foreign_key: { to_table: :users },
        index: !index_exists?(TABLE, column)
      )
    end

    unless index_exists?(TABLE, column)
      add_index(TABLE, column)
    end

    unless foreign_key_exists?(TABLE, column: column, to_table: :users)
      add_foreign_key(TABLE, :users, column: column)
    end
  end

  def add_column_unless_exists(name, type)
    add_column(TABLE, name, type) unless column_exists?(TABLE, name)
  end

  def remove_column_if_exists(name)
    remove_column(TABLE, name) if column_exists?(TABLE, name)
  end

  def remove_user_reference(name)
    column = "#{name}_id"

    if foreign_key_exists?(TABLE, column: column, to_table: :users)
      remove_foreign_key(TABLE, column: column)
    end

    remove_index(TABLE, column: column) if index_exists?(TABLE, column)

    remove_column(TABLE, column) if column_exists?(TABLE, column)
  end
end