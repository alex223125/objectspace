class AddOriginalAlgorithmVersionVersionNumberToAlgorithmVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :original_algorithm_version_version_number, :integer
  end
end
