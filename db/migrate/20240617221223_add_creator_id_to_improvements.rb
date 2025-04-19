class AddCreatorIdToImprovements < ActiveRecord::Migration[7.0]
  def change
    add_column :improvements, :creator_id, :integer
  end
end
