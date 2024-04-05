class AddCreatorIdToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :creator_id, :integer
  end
end
