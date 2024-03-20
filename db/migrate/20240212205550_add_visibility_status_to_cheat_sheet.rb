class AddVisibilityStatusToCheatSheet < ActiveRecord::Migration[7.0]
  def change
    add_column :cheat_sheets, :visibility_status, :integer
  end
end
