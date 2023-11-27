class AddArticleVersionIdToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :attachments, :article_version_id, :integer
  end
end
