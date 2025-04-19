class AddSlugToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :slug, :string
    add_index :logging_nodes, :slug, unique: true
  end
end
