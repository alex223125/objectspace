# app/controllers/api/algorithm_versions_controller.rb
require 'rqrcode'
require 'hexapdf' # FIX: Use native HexaPDF to completely bypass Puppeteer module dependencies

module Api
  class AlgorithmVersionsController < ApplicationController
    before_action :authenticate_user!
    protect_from_forgery with: :null_session

    def generate_passport
      version = Algorithms::AlgorithmVersion.find(params[:id])

      # 1. Update text metadata fields directly inside database structures
      version.update!(
        print_title: params[:print_title],
        short_print_description: params[:short_print_description]
      )

      version.update_column(:cached_qr_short_token, SecureRandom.alphanumeric(8).upcase) if version.cached_qr_short_token.blank?

      # 2. Compile pure vector path matrix shapes using the rqrcode engine
      target_url = "https://onrender.com{version.cached_qr_short_token}"
      # Ensure this line remains right above your binary_payload = "" block
      qrcode = ::RQRCode::QRCode.new(target_url, level: :h)


      svg_content = qrcode.as_svg(
        color: "4F46E5", # Match Indigo-600 UI color accent match
        shape_rendering: "crispEdges",
        module_size: 12,
        use_path: true,
        viewbox: true
      )

      # Store vector asset directly inside ActiveStorage
      version.qr_vector_blob.attach(
        io: StringIO.new(svg_content),
        filename: "qr_matrix_#{version.id}.svg",
        content_type: "image/svg+xml"
      )

      # 3. Compile high-fidelity PDF Document natively using pure Ruby configurations
      binary_payload = ""
      if params[:export_format] == "pdf"
        doc = HexaPDF::Document.new
        page = doc.pages.add([0, 0, 595.28, 841.89]) # Standard A4 layout bounds
        canvas = page.canvas

        # Draw Title Header (Top Margin Anchor)
        canvas.font('Helvetica', variant: :bold, size: 24)
        canvas.fill_color(17, 24, 39) # Slate-900
        canvas.text("Algorithm Verification Passport", at: [50, 750])

        # Draw Blueprint Tag Accent
        canvas.font('Helvetica', variant: :none, size: 10)
        canvas.fill_color(79, 70, 229) # Indigo-600 branding accent color
        canvas.text("PHYSICAL DEPLOYMENT BLUEPRINT", at: [50, 725])

        # Draw Dynamic Print Asset Display Title
        canvas.font('Helvetica', variant: :bold, size: 14)
        canvas.fill_color(30, 41, 59) # Slate-800
        canvas.text(version.print_title.to_s.truncate(50), at: [50, 680])

        # Draw Dynamic Short Print Summary Multi-line block
        canvas.font('Helvetica', variant: :none, size: 11)
        canvas.fill_color(100, 116, 139) # Slate-500
        canvas.text(version.short_print_description.to_s.truncate(140), at: [50, 650])

        # Draw solid boundary frame around the QR matrix block placement window
        canvas.stroke_color(226, 232, 240)
        canvas.rectangle(197, 400, 200, 200).stroke # Bounds perfectly centered horizontally



        # --- NATIVE QR MATRIX VECTOR RENDERING ENGINE PASS ---
        qr_modules = qrcode.modules
        matrix_size = qr_modules.size

        # Calculate sizes to automatically scale and center modules inside your 200x200 box
        box_size = 180.0 / matrix_size
        start_x = 197.0 + (200.0 - (box_size * matrix_size)) / 2.0
        start_y = 350.0 + (200.0 - (box_size * matrix_size)) / 2.0

        canvas.fill_color(79, 70, 229) # Fills the QR code modules with Indigo-600 color

        # Loop through rows and columns to draw pure vector rectangles onto the canvas
        qr_modules.each_with_index do |row, y|
          row.each_with_index do |is_dark, x|
            if is_dark
              # PDF y-coordinates start from the bottom, so we invert the row draw index
              pos_x = start_x + (x * box_size)
              pos_y = start_y + ((matrix_size - 1 - y) * box_size)
              canvas.rectangle(pos_x, pos_y, box_size, box_size).fill
            end
          end
        end
        




        # Render unique tracking token metadata string inside the page footer bounds
        canvas.font('Helvetica', variant: :italic, size: 10)
        canvas.fill_color(148, 163, 184)
        canvas.text("Token Tracker: #{version.cached_qr_short_token} • Objectspace Platform 2026", at: [50, 50])

        # Serialize document buffer matrix streams directly to memory structures
        io_stream = StringIO.new
        doc.write(io_stream)
        pdf_binary = io_stream.string

        # Attach the compiled print manifest document straight onto ActiveStorage
        version.printable_pdf_manifest.attach(
          io: StringIO.new(pdf_binary),
          filename: "blueprint_passport_#{version.id}.pdf",
          content_type: "application/pdf"
        )
        binary_payload = Base64.strict_encode64(pdf_binary)
      else
        binary_payload = Base64.strict_encode64(svg_content)
      end




      # Return parameters payload back to the Stimulus JavaScript client instantly
      render json: {
        success: true,
        inline_svg: svg_content,
        binary_file: binary_payload
      }, status: :ok
    end
  end
end
