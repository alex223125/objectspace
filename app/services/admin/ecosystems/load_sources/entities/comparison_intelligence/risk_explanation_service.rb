
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RiskExplanationService
            def initialize(registry: RiskFactorRegistry.new)
              @registry = registry
            end

            def call(factors:)
              normalized = Array(factors).filter_map do |factor|
                attributes = factor.to_h.stringify_keys
                definition = @registry.fetch(attributes["key"])

                next unless definition

                {
                  key: attributes["key"],
                  label: definition[:label],
                  description: attributes["description"].presence ||
                    definition[:description],
                  weight: definition[:weight],
                  severity: attributes["severity"].presence ||
                    definition[:severity],
                  evidence: attributes["evidence"],
                  path: attributes["path"]
                }
              end

              {
                factors: normalized,
                count: normalized.length,
                highest_severity: highest_severity(normalized),
                summary: summary(normalized)
              }
            end

            private

            def highest_severity(factors)
              priorities = {
                "critical" => 4,
                "high" => 3,
                "medium" => 2,
                "low" => 1
              }

              factors.max_by do |factor|
                priorities.fetch(factor[:severity].to_s, 0)
              end&.dig(:severity) || "low"
            end

            def summary(factors)
              return "No registered risk factors were identified." if factors.empty?

              labels = factors.map { |factor| factor[:label] }.uniq

              "#{factors.length} risk signal(s): #{labels.join(', ')}."
            end
          end
        end
      end
    end
  end
end