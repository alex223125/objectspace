# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationComparisonSerializer
          def self.call(result:)
            new(result: result).call
          end

          def initialize(result:)
            @result = result
          end

          def call
            {
              version: result.metadata.fetch(:version),
              deterministic: result.metadata.fetch(:deterministic),
              facts: result.facts.map(&:to_h),
              warnings: result.warnings.map(&:to_h)
            }
          end

          private

          attr_reader :result
        end
      end
    end
  end
end