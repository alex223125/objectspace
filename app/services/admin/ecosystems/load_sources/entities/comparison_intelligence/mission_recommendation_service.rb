
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class MissionRecommendationService
            def initialize(changes:, evidence_gaps: [])
              @changes = Array(changes)
              @evidence_gaps = Array(evidence_gaps)
            end

            def call
              missions = []

              critical = changes.count { |item| value(item, :risk).to_s == "critical" }
              high = changes.count { |item| value(item, :risk).to_s == "high" }
              unresolved = changes.count do |item|
                !ActiveModel::Type::Boolean.new.cast(value(item, :reviewed))
              end

              if critical.positive?
                missions << mission(
                  "resolve_critical_changes",
                  "Resolve critical changes",
                  critical,
                  "Review identity, factual and structural risks first.",
                  100
                )
              end

              if evidence_gaps.any?
                missions << mission(
                  "close_evidence_gaps",
                  "Close evidence gaps",
                  evidence_gaps.length,
                  "Attach and verify evidence for unsupported claims.",
                  85
                )
              end

              if high.positive?
                missions << mission(
                  "review_high_risk_changes",
                  "Review high-risk changes",
                  high,
                  "Inspect high-risk modifications before approving the comparison.",
                  70
                )
              end

              if unresolved.positive?
                missions << mission(
                  "complete_review_queue",
                  "Complete the review queue",
                  unresolved,
                  "Work through the remaining changes and record editorial decisions.",
                  50
                )
              end

              {
                total: missions.length,
                missions: missions.sort_by { |item| -item[:priority] }
              }
            end

            private

            attr_reader :changes, :evidence_gaps

            def value(item, key)
              return unless item.respond_to?(:[])

              item[key] || item[key.to_s]
            end

            def mission(key, title, count, description, priority)
              {
                key: key,
                title: title,
                count: count,
                description: description,
                priority: priority,
                status: "recommended"
              }
            end
          end
        end
      end
    end
  end
end