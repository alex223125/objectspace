class CreateResearchCollectionFindingMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :research_collection_finding_memberships do |t|
      t.references :research_collection_finding,
                   null: false,
                   foreign_key: true,
                   index: {
                     name: "idx_finding_memberships_finding"
                   }

      t.references :research_collection_membership,
                   null: false,
                   foreign_key: true,
                   index: {
                     name: "idx_finding_memberships_collection_membership"
                   }

      t.text :supporting_note

      t.timestamps
    end

    add_index :research_collection_finding_memberships,
              [:research_collection_finding_id,
               :research_collection_membership_id],
              unique: true,
              name: "idx_unique_finding_membership"
  end
end