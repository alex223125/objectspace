class AddResponsibilityTypeToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :responsibility_type, :integer
  end
end
