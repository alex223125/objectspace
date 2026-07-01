# app/jobs/algorithms/qr_vector_compilation_job.rb
module Algorithms
  class QrVectorCompilationJob < ApplicationJob
    queue_as :critical

    def perform(record_id, class_name)
      # Polymorphically locate the target algorithm version record
      record = class_name.constantize.find(record_id)
      return unless record.respond_to?(:cached_qr_short_token) && record.cached_qr_short_token.present?

      # Target shortened pointer destination URL layout
      target_url = "https://onrender.com{record.cached_qr_short_token}"

      # Compile vector matrix with a High error correction margin (:h)
      qrcode = RQRCode::QRCode.new(target_url, level: :h)

      svg_content = qrcode.as_svg(
        color: "4F46E5", # Custom Indigo-600 palette layout match
        shape_rendering: "crispEdges",
        module_size: 12,
        use_path: true,
        viewbox: true
      )

      # Write and link the raw inline SVG content to the ActiveStorage slot
      record.qr_vector_blob.attach(
        io: StringIO.new(svg_content),
        filename: "qr_matrix_#{record.cached_qr_short_token}.svg",
        content_type: "image/svg+xml",
        identify: false
      )

      # Build the high-fidelity print passport layout HTML string for Grover
      html_blueprint = ApplicationController.render(
        template: "tenant/prints/passport",
        layout: "layouts/pdf_manifest",
        assigns: { algorithm_version: record, svg_matrix_content: svg_content }
      )

      # Render the document HTML structure into raw binary bytes using Grover
      pdf_binary = Grover.new(html_blueprint, format: 'A4', print_background: true).to_pdf

      # Attach the compiled PDF document directly to the ActiveStorage manifest slot
      record.printable_pdf_manifest.attach(
        io: StringIO.new(pdf_binary),
        filename: "blueprint_passport_#{record.cached_qr_short_token}.pdf",
        content_type: "application/pdf",
        identify: false
      )
    end
  end
end
