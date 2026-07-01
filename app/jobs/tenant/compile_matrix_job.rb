module Tenant
  class CompileMatrixJob < ApplicationJob
    queue_as :critical

    def perform(version_id)
      version = AlgorithmVersion.find(version_id)
      lookup_token = SecureRandom.hex(4)

      short_url = "https://onrender.com{lookup_token}"
      qr_matrix = RQRCode::QRCode.new(short_url)

      svg_vector = qr_matrix.as_svg(
        color: "4F46E5",
        shape_rendering: "crispEdges",
        module_size: 12,
        use_path: true
      )

      version.create_tenant_qr_asset!(
        lookup_hash: lookup_token,
        cached_svg_matrix: svg_vector
      )
    end
  end
end