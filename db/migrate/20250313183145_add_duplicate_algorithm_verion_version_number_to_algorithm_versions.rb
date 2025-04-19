class AddDuplicateAlgorithmVerionVersionNumberToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :duplicate_algorithm_verion_version_number, :integer
  end
end
