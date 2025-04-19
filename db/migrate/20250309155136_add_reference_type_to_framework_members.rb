class AddReferenceTypeToFrameworkMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_members, :reference_type, :integer
  end
end
