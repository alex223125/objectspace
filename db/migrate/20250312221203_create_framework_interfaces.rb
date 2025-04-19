class CreateFrameworkInterfaces < ActiveRecord::Migration[7.0]
  def change
    create_table :framework_interfaces do |t|
      t.text :note

      t.timestamps
    end
  end
end
