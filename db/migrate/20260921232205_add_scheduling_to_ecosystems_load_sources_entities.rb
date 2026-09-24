# frozen_string_literal: true

class AddSchedulingToEcosystemsLoadSourcesEntities < ActiveRecord::Migration[7.0]
  def change
    change_table :ecosystems_load_sources_entities, bulk: true do |t|
      t.bigint :last_published_by_id
      t.index :last_published_by_id
    end
  end
end