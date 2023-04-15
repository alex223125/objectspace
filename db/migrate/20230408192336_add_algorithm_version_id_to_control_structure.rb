class AddAlgorithmVersionIdToControlStructure < ActiveRecord::Migration[7.0]
  def change
    add_column :control_structures, :algorithm_version_id, :integer
  end
end
