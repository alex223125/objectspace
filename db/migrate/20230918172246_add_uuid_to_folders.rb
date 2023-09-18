class AddUuidToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
