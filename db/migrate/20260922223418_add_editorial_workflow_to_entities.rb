# frozen_string_literal: true

class AddEditorialWorkflowToEntities < ActiveRecord::Migration[7.0]
  def change
    change_table :ecosystems_load_sources_entities, bulk: true do |t|
      t.bigint :assigned_reviewer_id
      t.datetime :review_requested_at
      t.datetime :reviewed_at
    end

    add_index \
      :ecosystems_load_sources_entities,
      :assigned_reviewer_id

    add_foreign_key \
      :ecosystems_load_sources_entities,
      :users,
      column: :assigned_reviewer_id,
      on_delete: :nullify
  end
end