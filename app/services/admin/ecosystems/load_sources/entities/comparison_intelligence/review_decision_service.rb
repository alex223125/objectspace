
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ReviewDecisionService
            DECISIONS = %w[approve reject request_changes defer].freeze

            def initialize(decision:, rationale:, reviewer_id:, requirements: [])
              @decision = decision.to_s
              @rationale = rationale.to_s.strip
              @reviewer_id = reviewer_id
              @requirements = Array(requirements)
            end

            def call
              errors = []
              errors << "invalid_decision" unless DECISIONS.include?(decision)
              errors << "reviewer_required" if reviewer_id.blank?
              errors << "rationale_required" if %w[reject request_changes].include?(decision) && rationale.blank?

              {
                valid: errors.empty?,
                errors: errors,
                decision: decision,
                rationale: rationale,
                reviewer_id: reviewer_id,
                requirements: requirements,
                submitted_at: Time.current.iso8601
              }
            end

            private

            attr_reader :decision, :rationale, :reviewer_id, :requirements
          end
        end
      end
    end
  end
end