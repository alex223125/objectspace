class CreateAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :algorithm_versions do |t|
      t.string :title
      t.text :solves_the_problem
      t.text :sources
      t.text :additional_information

      t.timestamps
    end
  end
end
