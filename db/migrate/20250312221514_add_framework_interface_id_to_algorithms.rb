class AddFrameworkInterfaceIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :framework_interface_id, :integer
  end
end
