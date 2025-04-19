class CreateLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    create_table :logging_nodes do |t|
      t.string :type
      t.integer :position

      t.timestamps
    end
  end
end
