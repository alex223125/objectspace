class RemovePositionFromUnits < ActiveRecord::Migration[7.0]
  def change
    remove_column :units, :position, :integer
  end
end
