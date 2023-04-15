class CreateControlStructures < ActiveRecord::Migration[7.0]
  def change
    create_table :control_structures do |t|
      t.string :type

      t.timestamps
    end
  end
end
