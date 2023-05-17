class AddMemberableToInterfaceMembers < ActiveRecord::Migration[7.0]
  def change
    add_reference :interface_members, :memberable, polymorphic: true, index: true
  end
end
