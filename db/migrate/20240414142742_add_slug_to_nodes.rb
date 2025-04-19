class AddSlugToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :slug, :string
    add_index :nodes, :slug, unique: true
  end
end
