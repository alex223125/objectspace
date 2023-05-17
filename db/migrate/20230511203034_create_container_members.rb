class CreateContainerMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :container_members do |t|

      t.timestamps
    end
  end
end
