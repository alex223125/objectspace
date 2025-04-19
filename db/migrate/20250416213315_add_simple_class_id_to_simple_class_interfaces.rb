class AddSimpleClassIdToSimpleClassInterfaces < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_interfaces, :simple_class_id, :integer
  end
end
