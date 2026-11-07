
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ReviewProgressService
            FINAL_STATES = %w[approved rejected resolved dismissed].freeze

            def initialize(changes:)
              @changes = Array(changes)
            end

            def call
              states = changes.map { |change| state_of(change) }
              total = states.length
              completed = states.count { |state| FINAL_STATES.include?(state) }

              {
                total: total,
                completed: completed,
                remaining: total - completed,
                completion_percentage: total.zero? ? 100 : (completed.to_f / total * 100).round,
                by_state: states.tally,
                fully_reviewed: completed == total
              }
            end

            private

            attr_reader :changes

            def state_of(change)
              value =
                if change.respond_to?(:[])
                  change[:review_state] || change["review_state"] ||
                    change[:status] || change["status"]
                end

              state = value.to_s.downcase
              %w[pending in_review approved rejected resolved dismissed].include?(state) ? state : "pending"
            end
          end
        end
      end
    end
  end
end