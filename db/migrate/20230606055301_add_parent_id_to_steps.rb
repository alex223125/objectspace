class AddParentIdToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :parent_id, :integer
  end
end
