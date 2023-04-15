class CreateUnitVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_versions do |t|
      t.string :title
      t.text :instruction
      t.text :solves_the_problem
      t.text :sources
      t.text :additional_information

      t.timestamps
    end
  end
end
