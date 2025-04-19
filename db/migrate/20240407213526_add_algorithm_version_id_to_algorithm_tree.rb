class AddAlgorithmVersionIdToAlgorithmTree < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_trees, :algorithm_version_id, :integer
  end
end
