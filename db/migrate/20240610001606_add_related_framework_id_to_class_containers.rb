class AddRelatedFrameworkIdToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :related_framework_id, :integer
  end
end
