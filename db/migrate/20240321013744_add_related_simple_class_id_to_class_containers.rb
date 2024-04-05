class AddRelatedSimpleClassIdToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :related_simple_class_id, :integer
  end
end
