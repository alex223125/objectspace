class RemoveTypeFromSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    remove_column :simple_classes, :type, :integer
  end
end
