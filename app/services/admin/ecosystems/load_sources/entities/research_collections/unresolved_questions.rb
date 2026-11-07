module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class UnresolvedQuestions
            def initialize(collection)
              @collection = collection
            end

            def call
              collection
                .questions
                .open_questions
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
