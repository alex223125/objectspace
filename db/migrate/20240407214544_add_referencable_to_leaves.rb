class AddReferencableToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_reference :leaves, :referencable, polymorphic: true, index: true
  end
end
