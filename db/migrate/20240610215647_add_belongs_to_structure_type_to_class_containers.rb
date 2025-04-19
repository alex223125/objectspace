# TODO: add null false constraint
class AddBelongsToStructureTypeToClassContainers < ActiveRecord::Migration[7.0]
  def change
    add_column :class_containers, :belongs_to_structure_type, :integer
  end
end
