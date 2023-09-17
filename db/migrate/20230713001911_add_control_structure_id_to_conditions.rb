class AddControlStructureIdToConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :conditions, :control_structure_id, :integer
  end
end
