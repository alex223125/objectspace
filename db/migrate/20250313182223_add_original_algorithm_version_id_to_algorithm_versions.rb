class AddOriginalAlgorithmVersionIdToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :original_algorithm_version_id, :integer,
               index: true, foreign_key: { to_table: :algorithm_versions }
  end
end
