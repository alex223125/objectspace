# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class BuildApplicationSemanticFacts
          def self.call(result:)
            new(result).call
          end

          def initialize(result)
            @result = result
          end

          def call
            ApplicationSemanticFacts.new(
              extract_facts
            )
          end

          private

          attr_reader :result

          def extract_facts
            source =
              existing_semantic_facts

            Array(source)
          end

          def existing_semantic_facts
            return result.semantic_facts if result.respond_to?(:semantic_facts)

            return result.facts if result.respond_to?(:facts)

            if result.respond_to?(:to_h)
              hash = result.to_h

              return hash[:semantic_facts] if hash.key?(:semantic_facts)
              return hash["semantic_facts"] if hash.key?("semantic_facts")

              return hash[:facts] if hash.key?(:facts)
              return hash["facts"] if hash.key?("facts")
            end

            []
          end
        end
      end
    end
  end
end