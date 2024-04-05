class AddCreatorIdToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :creator_id, :integer
  end
end
