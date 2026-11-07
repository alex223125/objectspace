
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RiskFactorRegistry
            FACTORS = {
              "identity_change" => {
                label: "Identity change",
                description: "A field used to identify the entity has changed.",
                weight: 35,
                severity: "high"
              },
              "removal" => {
                label: "Removal",
                description: "A previously present value has been removed.",
                weight: 25,
                severity: "medium"
              },
              "contradiction" => {
                label: "Contradiction",
                description: "Compared information may be inconsistent.",
                weight: 30,
                severity: "high"
              },
              "relationship_change" => {
                label: "Relationship change",
                description: "An entity relationship may have changed.",
                weight: 15,
                severity: "medium"
              },
              "low_evidence" => {
                label: "Low evidence coverage",
                description: "Supporting evidence may be insufficient.",
                weight: 20,
                severity: "medium"
              },
              "stale_evidence" => {
                label: "Stale evidence",
                description: "Supporting evidence may need freshness review.",
                weight: 10,
                severity: "low"
              }
            }.freeze

            def all
              FACTORS.deep_dup
            end

            def fetch(key)
              FACTORS[key.to_s]&.deep_dup
            end

            def keys
              FACTORS.keys
            end
          end
        end
      end
    end
  end
end