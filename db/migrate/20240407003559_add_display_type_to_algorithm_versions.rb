class AddDisplayTypeToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :display_type, :integer, null: false, default: AlgorithmVersions::DisplayTypes[:not_defined]
  end
end
