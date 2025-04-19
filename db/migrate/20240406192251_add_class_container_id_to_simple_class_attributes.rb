class AddClassContainerIdToSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_attributes, :class_container_id, :integer
  end
end
