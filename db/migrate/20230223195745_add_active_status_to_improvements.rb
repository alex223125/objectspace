class AddActiveStatusToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_column :improvements, :active_status, :integer
  end
end
