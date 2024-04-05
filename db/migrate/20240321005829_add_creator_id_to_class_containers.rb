class AddCreatorIdToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :creator_id, :integer
  end
end
