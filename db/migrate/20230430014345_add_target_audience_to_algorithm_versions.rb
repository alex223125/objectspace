class AddTargetAudienceToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :target_audience, :text
  end
end
