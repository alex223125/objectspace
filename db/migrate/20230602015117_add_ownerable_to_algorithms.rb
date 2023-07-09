class AddOwnerableToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_reference :algorithms, :ownerable, polymorphic: true, null: false, index: true
  end
end
