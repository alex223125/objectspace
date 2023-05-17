class AddSimpleClassIdToClassContainer < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :simple_class_id, :integer
  end
end
