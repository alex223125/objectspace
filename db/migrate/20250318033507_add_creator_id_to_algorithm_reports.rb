class AddCreatorIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :creator_id, :integer
  end
end
