class AddUnitVersionIdToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :attachments, :unit_version_id, :integer
  end
end
