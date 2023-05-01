class AddIndexToSearchableAlgorithmVersions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :algorithm_versions, :searchable, using: :gin, algorithm: :concurrently
  end
end