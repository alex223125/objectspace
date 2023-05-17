class AddParentIdToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :parent_id, :integer
  end
end
