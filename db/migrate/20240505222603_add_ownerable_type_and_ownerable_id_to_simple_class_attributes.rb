class AddOwnerableTypeAndOwnerableIdToSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_attributes, :ownerable_type, :string
    add_column :simple_class_attributes, :ownerable_id, :integer
  end
end
