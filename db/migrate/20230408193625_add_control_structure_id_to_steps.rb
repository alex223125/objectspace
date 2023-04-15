class AddControlStructureIdToSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :steps, :control_structure_id, :integer
  end
end
