class AddDescriptionToNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :nodes, :description, :text
  end
end
