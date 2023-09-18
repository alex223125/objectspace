class AddRepositoryIdToFrameworks < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks, :repository_id, :integer
  end
end
