class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.references :permissionable, polymorphic: true, null: false
      t.references :actorable, polymorphic: true, null: false

      t.integer :allowed_action_type, null: false
      t.integer :source_type, null: false

      t.timestamps
    end
  end
end