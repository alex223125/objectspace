class AddSlugToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :slug, :string
    add_index :class_containers, :slug, unique: true
  end
end