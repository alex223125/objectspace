class AddSlugToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_column :improvements, :slug, :string
    add_index :improvements, :slug, unique: true
  end
end
