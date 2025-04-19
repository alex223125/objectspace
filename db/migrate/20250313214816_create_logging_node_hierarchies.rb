class CreateLoggingNodeHierarchies < ActiveRecord::Migration[7.0]
  def change
    create_table :logging_node_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :logging_node_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "logging_node_anc_desc_idx"

    add_index :logging_node_hierarchies, [:descendant_id],
      name: "logging_node_desc_idx"
  end
end
