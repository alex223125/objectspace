class AddCreatorIdToFrameworkFolder < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_folders, :creator_id, :integer
  end
end
