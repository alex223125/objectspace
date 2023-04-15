class AddPositionToUnit < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :position, :integer
  end
end
