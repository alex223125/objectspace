class AddBackendStorageTypeIdToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :backend_storage_type_id, :integer
  end
end
