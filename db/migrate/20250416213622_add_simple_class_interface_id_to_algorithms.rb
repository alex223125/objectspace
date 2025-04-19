class AddSimpleClassInterfaceIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :simple_class_interface_id, :integer
  end
end
