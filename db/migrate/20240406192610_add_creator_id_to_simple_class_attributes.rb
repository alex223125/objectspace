class AddCreatorIdToSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_attributes, :creator_id, :integer
  end
end
