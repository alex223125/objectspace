class AddFrameworkIdToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :framework_id, :integer
  end
end
