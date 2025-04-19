class CreateAlgorithmReports < ActiveRecord::Migration[7.0]
  def change
    create_table :algorithm_reports do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
