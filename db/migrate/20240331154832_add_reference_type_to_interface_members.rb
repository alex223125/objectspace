class AddReferenceTypeToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :interface_members, :reference_type, :integer, null: false
  end
end