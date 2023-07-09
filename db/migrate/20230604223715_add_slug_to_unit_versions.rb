class AddSlugToUnitVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_versions, :slug, :string
    add_index :unit_versions, :slug, unique: true
  end
end
