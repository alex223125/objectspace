class AddAlgorithmIdToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :algorithm_id, :integer
  end
end
