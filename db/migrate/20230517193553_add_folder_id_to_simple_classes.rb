class AddFolderIdToSimpleClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_classes, :folder_id, :integer
  end
end
