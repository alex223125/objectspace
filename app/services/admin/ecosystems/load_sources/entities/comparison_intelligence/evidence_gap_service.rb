
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EvidenceGapService
            def call(changes:)
              Array(changes).filter_map do |change|
                attributes = change.to_h.stringify_keys

                next if evidence_present?(attributes)

                {
                  change_id: attributes["id"],
                  path: attributes["path"].presence || "Unknown path",
                  change_type: attributes["type"].presence || "changed",
                  priority: priority_for(attributes),
                  reason: "No supporting evidence was supplied.",
                  recommended_action: "Attach a citation or source record.",
                  status: "open"
                }
              end.sort_by do |gap|
                { "high" => 0, "medium" => 1, "low" => 2 }.fetch(
                  gap[:priority], 2
                )
              end
            end

            private

            def evidence_present?(attributes)
              attributes["evidence"].present? ||
                Array(attributes["evidence_ids"]).any?(&:present?) ||
                Array(attributes["evidence_references"]).any?(&:present?)
            end

            def priority_for(attributes)
              return "high" if attributes["risk"].to_s == "critical"
              return "high" if attributes["risk"].to_s == "high"
              return "medium" if attributes["type"].to_s == "removed"

              "low"
            end
          end
        end
      end
    end
  end
end