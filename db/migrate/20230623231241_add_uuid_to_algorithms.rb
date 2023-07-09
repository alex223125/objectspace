class AddUuidToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
