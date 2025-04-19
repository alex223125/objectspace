class AddNodeNoteToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :node_note, :text
  end
end
