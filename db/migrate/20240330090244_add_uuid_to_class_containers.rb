class AddUuidToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
