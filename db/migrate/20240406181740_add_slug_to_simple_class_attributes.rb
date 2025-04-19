class AddSlugToSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_attributes, :slug, :string
    add_index :simple_class_attributes, :slug, unique: true
  end
end
