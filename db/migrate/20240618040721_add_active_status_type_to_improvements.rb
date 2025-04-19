class AddActiveStatusTypeToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_column :improvements, :active_status_type, :integer, null: false
  end
end
