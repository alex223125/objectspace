class AddRepositoryIdToFolder < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :repository_id, :integer
  end
end
