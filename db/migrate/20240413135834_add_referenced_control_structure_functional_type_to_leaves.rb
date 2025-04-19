class AddReferencedControlStructureFunctionalTypeToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :referenced_control_structure_functional_type, :integer
  end
end
