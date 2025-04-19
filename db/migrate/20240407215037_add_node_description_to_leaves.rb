class AddNodeDescriptionToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :node_description, :text
  end
end
