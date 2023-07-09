class AddSlugToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :slug, :string
    add_index :simple_classes, :slug, unique: true
  end
end
