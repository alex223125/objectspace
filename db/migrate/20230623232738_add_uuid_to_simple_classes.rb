class AddUuidToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
