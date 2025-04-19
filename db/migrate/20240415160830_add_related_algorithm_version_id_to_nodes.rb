class AddRelatedAlgorithmVersionIdToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :related_algorithm_version_id, :integer
  end
end
