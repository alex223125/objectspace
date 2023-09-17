class AddFunctionalTypeToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :functional_type, :integer
  end
end
