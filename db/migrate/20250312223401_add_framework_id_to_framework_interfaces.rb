class AddFrameworkIdToFrameworkInterfaces < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_interfaces, :framework_id, :integer
  end
end
