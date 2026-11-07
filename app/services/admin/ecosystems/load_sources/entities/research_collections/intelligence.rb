module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class Intelligence
            def initialize(collection)
              @collection = collection
            end

            def call
              base = IntelligenceBuilder.new(collection).call

              base.merge(
                contradictions: ContradictionDetector.new(collection).call,
                unresolved_questions: UnresolvedQuestions.new(collection).call,
                evidence_coverage: EvidenceCoverage.new(collection).call
              )
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end