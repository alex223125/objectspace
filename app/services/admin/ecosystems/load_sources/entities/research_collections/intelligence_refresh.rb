module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class IntelligenceRefresh
            def initialize(collection)
              @collection = collection
            end

            def call
              ApplicationRecord.transaction do
                SignalSynchronizer
                  .new(collection)
                  .call

                FindingsSynchronizer
                  .new(collection)
                  .call

                RelationshipSynchronizer
                  .new(collection)
                  .call

                collection.intelligence_refresh!
              end

              IntelligenceBuilder
                .new(collection)
                .call
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end
