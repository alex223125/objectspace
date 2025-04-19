class AddUuidToFrameworkMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_members, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
