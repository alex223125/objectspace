class AddUserIdToDashboard < ActiveRecord::Migration[7.0]
  def change
    add_column :dashboards, :user_id, :integer
  end
end
