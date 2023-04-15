class AddAlgorithmIdToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :algorithm_id, :integer
  end
end
