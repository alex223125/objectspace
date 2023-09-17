class AddDescriptionToUnitVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_versions, :description, :text
  end
end
