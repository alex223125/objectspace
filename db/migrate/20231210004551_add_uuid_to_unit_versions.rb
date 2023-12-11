class AddUuidToUnitVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_versions, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end