class AddPositionToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :position, :integer, null: false
  end
end