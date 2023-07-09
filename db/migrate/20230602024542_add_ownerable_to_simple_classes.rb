class AddOwnerableToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_reference :simple_classes, :ownerable, polymorphic: true, null: false, index: true
  end
end
