class AddTargetAudienceToUnitVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_versions, :target_audience, :text
  end
end
