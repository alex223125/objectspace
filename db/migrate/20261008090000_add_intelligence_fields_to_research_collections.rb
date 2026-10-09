class AddIntelligenceFieldsToResearchCollections < ActiveRecord::Migration[7.0]
  def change
    change_table :research_collections, bulk: true do |t|
      t.string :research_question, null: true
      t.text :objective, null: true
      t.text :synthesis, null: true
      t.integer :priority, null: false, default: 0
      t.datetime :last_intelligence_refresh_at
    end
  end
end