class AddSlugToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :slug, :string
    add_index :algorithm_versions, :slug, unique: true
  end
end
