class AddWizardCreationStageIdAddToAlgorithms < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithms, :wizard_creation_stage_id, :integer, default: 1, required: true
  end
end
