class AddVisibilityStatusToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :visibility_status, :integer
  end
end
