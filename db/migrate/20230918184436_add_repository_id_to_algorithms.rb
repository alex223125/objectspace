class AddRepositoryIdToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :repository_id, :integer
  end
end
