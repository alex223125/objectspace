class AddBackendStorageTypeIdToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :backend_storage_type_id, :integer
  end
end
