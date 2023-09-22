class AddNodeIdToAttachment < ActiveRecord::Migration[7.0]
  def change
    add_column :attachments, :node_id, :integer
  end
end
