class RemoveDescriptionFromAlgorithms < ActiveRecord::Migration[7.0]
  def change
    remove_column :algorithms, :description, :text
  end
end
