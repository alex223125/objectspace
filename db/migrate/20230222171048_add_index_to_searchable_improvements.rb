class AddIndexToSearchableImprovements < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :improvements, :searchable, using: :gin, algorithm: :concurrently
  end
end