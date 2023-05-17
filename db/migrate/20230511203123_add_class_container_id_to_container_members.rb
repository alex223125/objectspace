class AddClassContainerIdToContainerMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :container_members, :class_container_id, :integer
  end
end
