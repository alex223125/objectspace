class AddOwnerableTypeAndOwnerableIdToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :ownerable_type, :string
    add_column :folders, :ownerable_id, :integer
  end
end
