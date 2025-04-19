class AddRelatedFrameworkIdToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :related_framework_id, :integer
  end
end
