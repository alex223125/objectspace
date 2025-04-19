class AddUuidToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
