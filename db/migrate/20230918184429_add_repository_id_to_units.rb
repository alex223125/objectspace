class AddRepositoryIdToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :repository_id, :integer
  end
end
