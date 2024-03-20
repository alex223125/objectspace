class AddOwnerableTypeAndOwnerableIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :ownerable_type, :string
    add_column :repositories, :ownerable_id, :integer
  end
end
