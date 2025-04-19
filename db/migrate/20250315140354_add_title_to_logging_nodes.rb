class AddTitleToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :title, :string
  end
end
