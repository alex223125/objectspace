class CreateResearchCollectionMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_memberships do |t|
      t.references :research_collection,
                   null: false,
                   foreign_key: true

      t.references :research_workspace,
                   null: false,
                   foreign_key: true

      t.integer :position, null: false, default: 0
      t.boolean :pinned, null: false, default: false
      t.text :notes
      t.datetime :pinned_at

      t.timestamps
    end

    add_index :research_collection_memberships,
              [
                :research_collection_id,
                :research_workspace_id
              ],
              unique: true,
              name: "idx_collection_memberships_unique_workspace"

    add_index :research_collection_memberships,
              [
                :research_collection_id,
                :position
              ],
              name: "idx_collection_memberships_collection_position"

    add_index :research_collection_memberships,
              [
                :research_collection_id,
                :pinned
              ],
              name: "idx_collection_memberships_collection_pinned"
  end
end