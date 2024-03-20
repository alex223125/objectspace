class AddRepositoryIdToCheatSheet < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :repository_id, :integer
  end
end
