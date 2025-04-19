class CreateSimpleClassInterfaces < ActiveRecord::Migration[7.0]
  def change
    create_table :simple_class_interfaces do |t|
      t.text :note

      t.timestamps
    end
  end
end
