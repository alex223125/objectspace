class AddParentIdToFrameworkFolder < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :parent_id, :integer
  end
end
