class AddPositionToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :position, :integer, null: false
    add_index :steps, :position, unique: true
  end
end
