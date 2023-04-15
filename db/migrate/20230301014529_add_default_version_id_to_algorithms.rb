class AddDefaultVersionIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :default_version_id, :integer
  end
end
