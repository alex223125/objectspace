class AddDefaultVersionIdToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :default_version_id, :integer
  end
end
