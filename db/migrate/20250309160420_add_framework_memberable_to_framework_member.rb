class AddFrameworkMemberableToFrameworkMember < ActiveRecord::Migration[7.0]
  def change
    add_reference :framework_members, :framework_memberable, polymorphic: true, null: false
  end
end
