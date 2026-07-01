class CreateTenantQrAssetsToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :tenant_qr_assets do |t|
      t.references :algorithm_version, null: false, foreign_key: true
      t.string :lookup_hash, null: false, index: { unique: true }
      t.text :cached_svg_matrix
      t.string :configured_foreground, default: "#4F46E5"
      t.timestamps
    end
  end
end
