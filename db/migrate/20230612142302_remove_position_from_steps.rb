class RemovePositionFromSteps < ActiveRecord::Migration[7.0]
  def change
    remove_column :steps, :position, :integer
  end
end
