class CreateLinkAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :link_attachments do |t|
      t.references :linkable, polymorphic: true, null: false

      t.timestamps
    end
  end
end