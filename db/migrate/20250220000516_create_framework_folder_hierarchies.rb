class CreateFrameworkFolderHierarchies < ActiveRecord::Migration[7.0]
  def change
    create_table :framework_folder_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :framework_folder_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "framework_folder_anc_desc_idx"

    add_index :framework_folder_hierarchies, [:descendant_id],
      name: "framework_folder_desc_idx"
  end
end
