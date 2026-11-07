
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class AnnotationService
            MAX_LENGTH = 5_000
            TYPES = %w[comment question evidence concern suggestion].freeze

            def initialize(body:, author_id:, annotation_type: "comment", target_id: nil)
              @body = body.to_s.strip
              @author_id = author_id
              @annotation_type = annotation_type.to_s
              @target_id = target_id
            end

            def call
              errors = []
              errors << "body_required" if body.blank?
              errors << "body_too_long" if body.length > MAX_LENGTH
              errors << "author_required" if author_id.blank?
              errors << "invalid_annotation_type" unless TYPES.include?(annotation_type)

              {
                valid: errors.empty?,
                errors: errors,
                annotation: {
                  body: body,
                  author_id: author_id,
                  annotation_type: annotation_type,
                  target_id: target_id,
                  created_at: Time.current.iso8601
                }
              }
            end

            private

            attr_reader :body, :author_id, :annotation_type, :target_id
          end
        end
      end
    end
  end
end