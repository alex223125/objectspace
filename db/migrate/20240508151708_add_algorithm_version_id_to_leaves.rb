class AddAlgorithmVersionIdToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :algorithm_version_id, :integer
  end
end
