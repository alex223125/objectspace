class AddImprovableToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_reference :improvements, :improvable, polymorphic: true, null: false, index: true
  end
end
