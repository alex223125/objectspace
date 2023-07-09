class AddOwnerableToUnits < ActiveRecord::Migration[7.0]
  def change
    add_reference :units, :ownerable, polymorphic: true, null: false, index: true
  end
end
