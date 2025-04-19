class AddCreatorIdToFrameworks < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks, :creator_id, :integer
  end
end
