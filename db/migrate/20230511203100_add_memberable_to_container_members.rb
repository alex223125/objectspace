class AddMemberableToContainerMembers < ActiveRecord::Migration[7.0]
  def change
    add_reference :container_members, :memberable, polymorphic: true, index: true
  end
end
