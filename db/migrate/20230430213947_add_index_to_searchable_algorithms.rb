class AddIndexToSearchableAlgorithms < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :algorithms, :searchable, using: :gin, algorithm: :concurrently
  end
end