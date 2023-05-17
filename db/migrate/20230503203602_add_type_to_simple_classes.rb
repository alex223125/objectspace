class AddTypeToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :type, :integer
  end
end
