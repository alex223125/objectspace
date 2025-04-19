class AddOwnerableToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_reference :improvements, :ownerable, polymorphic: true, null: false, index: true
  end
end
