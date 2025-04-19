class CreateNodes < ActiveRecord::Migration[7.0]
  def change
    create_table :nodes do |t|
      t.string :type, null: false
      t.integer "position", null: false
      t.string :title

      t.text :instruction
      t.text :step_finish_check
      t.text :solves_the_problem
      t.text :sources
      t.text :additional_information
      t.integer :parent_step_id
      t.text :note
      t.integer :step_functional_type

      t.integer :control_structure_id
      t.integer :control_structure_functional_type

      t.timestamps
    end
  end
end

