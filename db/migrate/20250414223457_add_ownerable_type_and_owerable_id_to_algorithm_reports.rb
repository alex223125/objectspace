class AddOwnerableTypeAndOwerableIdToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :ownerable_type, :string
    add_column :algorithm_reports, :ownerable_id, :integer
  end
end
