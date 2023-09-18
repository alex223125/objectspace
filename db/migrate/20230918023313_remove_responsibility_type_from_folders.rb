class RemoveResponsibilityTypeFromFolders < ActiveRecord::Migration[7.0]
  def change
    remove_column :folders, :responsibility_type, :integer
  end
end
