
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EvidenceCoverageService
            def call(changes:)
              items = Array(changes)
              covered = items.count { |item| evidence_present?(item) }
              total = items.length

              {
                total_changes: total,
                covered_changes: covered,
                uncovered_changes: total - covered,
                coverage_percentage: total.zero? ? 100 :
                                       ((covered.to_f / total) * 100).round(1),
                status: status_for(total.zero? ? 100 : (covered.to_f / total * 100))
              }
            end

            private

            def evidence_present?(item)
              attributes = item.to_h.stringify_keys

              evidence = attributes["evidence"]
              evidence_ids = attributes["evidence_ids"]
              references = attributes["evidence_references"]

              evidence.present? ||
                Array(evidence_ids).any?(&:present?) ||
                Array(references).any?(&:present?)
            end

            def status_for(percentage)
              case percentage
              when 90..100 then "strong"
              when 65...90 then "moderate"
              when 35...65 then "weak"
              else "insufficient"
              end
            end
          end
        end
      end
    end
  end
end