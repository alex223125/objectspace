class CreateAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :attachments do |t|
      t.string "attachable_type", null: false
      t.integer "attachable_id", null: false
      t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"

      t.timestamps
    end
  end
end
