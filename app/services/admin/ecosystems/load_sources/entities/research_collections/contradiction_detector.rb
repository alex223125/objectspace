module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class ContradictionDetector
            def initialize(collection)
              @collection = collection
            end

            def call
              collection
                .synthesis_notes
                .contradictions
                .ordered
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end
