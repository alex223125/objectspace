
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ReviewPolicyService
            DEFAULT_POLICY = {
              require_independent_review_for_critical: true,
              require_evidence_for_additions: false,
              minimum_reviewers: 1
            }.freeze

            def initialize(changes:, policy: {})
              @changes = Array(changes)
              @policy = DEFAULT_POLICY.merge(policy.symbolize_keys)
            end

            def call
              requirements = []

              critical = changes.select { |item| value(item, :risk).to_s == "critical" }
              additions = changes.select { |item| value(item, :type).to_s == "added" }

              if policy[:require_independent_review_for_critical] && critical.any?
                requirements << {
                  key: "independent_critical_review",
                  title: "Independent review of critical changes",
                  count: critical.length,
                  required: true
                }
              end

              if policy[:require_evidence_for_additions] && additions.any?
                requirements << {
                  key: "addition_evidence",
                  title: "Evidence required for additions",
                  count: additions.length,
                  required: true
                }
              end

              {
                minimum_reviewers: [policy[:minimum_reviewers].to_i, 1].max,
                requirements: requirements,
                blocking: requirements.any? { |item| item[:required] },
                change_count: changes.length
              }
            end

            private

            attr_reader :changes, :policy

            def value(item, key)
              item.respond_to?(:[]) ? item[key] || item[key.to_s] : nil
            end
          end
        end
      end
    end
  end
end