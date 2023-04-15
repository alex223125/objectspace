class AddPositionToStep < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :position, :integer
  end
end
