class CreateInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :interface_members do |t|

      t.timestamps
    end
  end
end
