class AddTypeToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :type, :integer
  end
end
