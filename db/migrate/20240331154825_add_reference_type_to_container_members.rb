class AddReferenceTypeToContainerMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :container_members, :reference_type, :integer, null: false
  end
end
