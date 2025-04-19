class AddUuidToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
