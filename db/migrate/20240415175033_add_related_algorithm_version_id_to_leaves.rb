class AddRelatedAlgorithmVersionIdToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :related_algorithm_version_id, :integer
  end
end
