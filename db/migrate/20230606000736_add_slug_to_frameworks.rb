class AddSlugToFrameworks < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks, :slug, :string
    add_index :frameworks, :slug, unique: true
  end
end
