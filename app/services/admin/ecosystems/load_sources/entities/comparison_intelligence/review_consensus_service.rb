
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ReviewConsensusService
            FINAL_DECISIONS = %w[approve reject].freeze

            def initialize(decisions:, minimum_reviewers: 1)
              @decisions = Array(decisions)
              @minimum_reviewers = [minimum_reviewers.to_i, 1].max
            end

            def call
              votes = decisions.filter_map do |decision|
                value = decision.respond_to?(:[]) ? decision[:decision] || decision["decision"] : nil
                normalized = value.to_s.downcase
                normalized if FINAL_DECISIONS.include?(normalized)
              end

              counts = votes.tally
              reviewers = decisions.length
              disagreement = counts["approve"].to_i.positive? && counts["reject"].to_i.positive?

              status =
                if reviewers < minimum_reviewers
                  "insufficient_reviewers"
                elsif disagreement
                  "disagreement"
                elsif votes.empty?
                  "pending"
                elsif counts["approve"] == votes.length
                  "approved_by_recorded_votes"
                elsif counts["reject"] == votes.length
                  "rejected_by_recorded_votes"
                else
                  "pending"
                end

              {
                status: status,
                decision_counts: counts,
                reviewer_count: reviewers,
                final_vote_count: votes.length,
                disagreement: disagreement,
                requires_human_resolution: disagreement || status == "insufficient_reviewers"
              }
            end

            private

            attr_reader :decisions, :minimum_reviewers
          end
        end
      end
    end
  end
end