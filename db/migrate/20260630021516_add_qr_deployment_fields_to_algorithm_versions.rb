class AddQrDeploymentFieldsToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    change_table :algorithm_versions, bulk: true do |t|
      # Limit string sizes to match model length validations exactly
      t.string :print_title, limit: 60
      t.string :short_print_description, limit: 160
      t.string :cached_qr_short_token, limit: 12
    end

    # Enforce database-level safety limits to prevent routing duplicates
    add_index :algorithm_versions, :cached_qr_short_token, unique: true
  end
end
