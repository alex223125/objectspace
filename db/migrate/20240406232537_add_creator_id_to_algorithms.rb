class AddCreatorIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :creator_id, :integer
  end
end
