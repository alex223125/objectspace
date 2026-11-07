# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
      module DiffIntelligence
        class ApplicationComparison
          attr_reader :facts, :insight

          def self.call(
            result:,
            comparison_insight: nil
          )
            new(
              result: result,
              comparison_insight: comparison_insight
            ).call
          end

          def initialize(
            result:,
            comparison_insight: nil
          )
            @result = result
            @comparison_insight = comparison_insight
          end

          def call
            application_facts =
              ApplicationFacts.call(
                result: result
              )

            @facts = application_facts.facts
            @insight = comparison_insight

            self
          end

          def to_h
            {
              facts: facts.map(&:to_h),
              insight: serialize_insight(insight)
            }
          end

          def as_json(*)
            to_h
          end

          private

          attr_reader :result, :comparison_insight

          def serialize_insight(value)
            return nil if value.nil?

            if value.respond_to?(:to_h)
              value.to_h
            else
              value
            end
          end
        end
      end
    end
  end
  end
end
