# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_review_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphReviewService
            VALID_DECISIONS = %w[approve reject defer].freeze

            def initialize(review_scope:)
              unless review_scope.respond_to?(:find_by)
                raise ArgumentError, "review_scope must be an authorized ActiveRecord relation"
              end

              @review_scope = review_scope
            end

            # Returns the record for display; does not change persistence.
            def find(review_id:)
              record = @review_scope.find_by(id: review_id)

              {
                found: record.present?,
                review: record&.attributes
              }
            end

            # Validates a requested decision without persisting it.
            # Persistence belongs in a model-specific workflow after authorization.
            def validate_decision(decision:, reviewer_id:, reason: nil)
              normalized = decision.to_s

              errors = []
              errors << "Unsupported decision" unless VALID_DECISIONS.include?(normalized)
              errors << "Reviewer is required" if reviewer_id.blank?
              errors << "A reason is required for rejection" if normalized == "reject" && reason.blank?

              {
                valid: errors.empty?,
                decision: normalized,
                reviewer_id: reviewer_id,
                reason: reason,
                errors: errors
              }
            end
          end
        end
      end
    end
  end
end