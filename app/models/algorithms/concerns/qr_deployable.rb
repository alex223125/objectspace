module Algorithms
  module Concerns
    module QrDeployable
    extend ActiveSupport::Concern

    included do
      has_one_attached :qr_vector_blob
      has_one_attached :printable_pdf_manifest

      validates :print_title, presence: true, length: { maximum: 60 }, on: :update, if: :will_save_change_to_print_title?
      validates :short_print_description, presence: true, length: { maximum: 160 }, on: :update, if: :will_save_change_to_short_print_description?

      before_validation :ensure_cached_qr_short_token, on: :create
      after_commit :enqueue_heavy_vector_compilation, on: :update, if: :saved_change_to_print_title?
    end

    def secure_landing_url
      "https://onrender.com{cached_qr_short_token}"
    end

    private

    def ensure_cached_qr_short_token
      self.cached_qr_short_token ||= SecureRandom.alphanumeric(8).upcase
    end

    def enqueue_heavy_vector_compilation
      # Delegate rendering to background tasks to protect live database throughput
      Algorithms::QrVectorCompilationJob.perform_later(id, self.class.name)
    end
    end
  end
end
