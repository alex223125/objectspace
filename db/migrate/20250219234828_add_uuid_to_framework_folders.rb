class AddUuidToFrameworkFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
