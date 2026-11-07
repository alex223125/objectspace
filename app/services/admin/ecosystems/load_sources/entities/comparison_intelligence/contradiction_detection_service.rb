
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ContradictionDetectionService
            def call(changes:)
              Array(changes).filter_map do |change|
                attributes = change.to_h.stringify_keys

                explicit = ActiveModel::Type::Boolean.new.cast(
                  attributes["contradiction"]
                )

                conflicting = attributes["conflicting_values"]

                next unless explicit || conflicting.is_a?(Array) &&
                  conflicting.length > 1

                {
                  id: attributes["id"],
                  path: attributes["path"].presence || "Unknown path",
                  field: attributes["field"].presence || attributes["path"],
                  values: conflicting || [
                    attributes["before"],
                    attributes["after"]
                  ].compact,
                  severity: normalize_severity(attributes["severity"]),
                  explanation: attributes["contradiction_explanation"].presence ||
                    "Conflicting values require editorial verification.",
                  requires_review: true
                }
              end
            end

            private

            def normalize_severity(value)
              %w[low medium high critical].include?(value.to_s) ?
                value.to_s : "medium"
            end
          end
        end
      end
    end
  end
end