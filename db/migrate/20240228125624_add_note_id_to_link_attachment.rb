class AddNoteIdToLinkAttachment < ActiveRecord::Migration[7.0]
  def change
    add_column :link_attachments, :note_id, :integer
  end
end
