# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ComparisonPresenter
          def self.call(result:)
            new(result: result).call
          end

          def initialize(result:)
            @result = result
          end

          def call
            {
              diff: result,
              gamification:
                Gamification::Analyzer.call(result: result)
            }
          end

          private

          attr_reader :result
        end
      end
    end
  end
end