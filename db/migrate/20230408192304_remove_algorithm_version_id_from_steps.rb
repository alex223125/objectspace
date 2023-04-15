class RemoveAlgorithmVersionIdFromSteps < ActiveRecord::Migration[7.0]
  def change
    remove_column :steps, :algorithm_version_id, :integer
  end
end
