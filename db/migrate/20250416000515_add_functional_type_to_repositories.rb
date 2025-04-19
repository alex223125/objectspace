class AddFunctionalTypeToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :functional_type, :integer
  end
end
