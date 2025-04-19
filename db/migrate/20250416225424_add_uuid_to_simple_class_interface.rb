class AddUuidToSimpleClassInterface < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_class_interfaces, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
