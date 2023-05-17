class CreateClassContainerHierarchies < ActiveRecord::Migration[7.0]
  def change
    create_table :class_container_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :class_container_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "class_container_anc_desc_idx"

    add_index :class_container_hierarchies, [:descendant_id],
      name: "class_container_desc_idx"
  end
end
