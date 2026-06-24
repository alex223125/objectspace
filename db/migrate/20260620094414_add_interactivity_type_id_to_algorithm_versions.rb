class AddInteractivityTypeIdToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :interactivity_type_id, :integer, default: 1, required: true
  end
end
