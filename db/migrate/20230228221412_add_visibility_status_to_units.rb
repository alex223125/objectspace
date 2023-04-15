class AddVisibilityStatusToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :visibility_status, :integer
  end
end
