class CreateSimpleClassAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :simple_class_attributes do |t|

      t.timestamps
    end
  end
end
