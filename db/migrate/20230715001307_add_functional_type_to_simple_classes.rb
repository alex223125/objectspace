class AddFunctionalTypeToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :functional_type, :integer, null: false
  end
end
