
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class IdentityRiskService
            def initialize(registry: RiskFactorRegistry.new)
              @registry = registry
            end

            def call(changes:)
              factors = Array(changes).filter_map do |change|
                attributes = change.to_h.stringify_keys
                key = factor_for(attributes)

                next unless key

                definition = @registry.fetch(key)
                next unless definition

                {
                  key: key,
                  path: attributes["path"],
                  description: definition[:description],
                  severity: definition[:severity],
                  evidence: attributes["id"] || attributes["key"]
                }
              end

              weight_total = factors.sum do |factor|
                @registry.fetch(factor[:key]).fetch(:weight)
              end

              score = [weight_total, 100].min

              {
                score: score,
                level: level_for(score),
                factors: factors,
                factor_count: factors.length,
                requires_review: score >= 35
              }
            end

            private

            def factor_for(attributes)
              return "identity_change" if boolean?(attributes["identity_field"])
              return "identity_change" if boolean?(attributes["identity_risk"])
              return "identity_change" if attributes["classification"] == "identity"
              return "removal" if attributes["type"] == "removed" &&
                boolean?(attributes["identity_field"])

              nil
            end

            def boolean?(value)
              ActiveModel::Type::Boolean.new.cast(value)
            end

            def level_for(score)
              case score
              when 0..19 then "low"
              when 20..44 then "medium"
              when 45..69 then "high"
              else "critical"
              end
            end
          end
        end
      end
    end
  end
end