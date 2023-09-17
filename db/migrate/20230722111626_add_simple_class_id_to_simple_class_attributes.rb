class AddSimpleClassIdToSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_attributes, :simple_class_id, :integer
  end
end
