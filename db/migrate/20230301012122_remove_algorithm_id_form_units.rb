class RemoveAlgorithmIdFormUnits < ActiveRecord::Migration[7.0]
  def change
    remove_column :units, :algorithm_id, :integer
  end
end
