class AddFunctionalTypeToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :functional_type, :integer, null: false
  end
end
