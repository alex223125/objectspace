class AddSlugToAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_reports, :slug, :string
    add_index :algorithm_reports, :slug, unique: true
  end
end
