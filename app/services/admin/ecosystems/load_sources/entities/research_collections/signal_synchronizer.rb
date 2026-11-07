module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class SignalSynchronizer
            def initialize(collection)
              @collection = collection
            end

            def call
              signals = SignalDeriver.new(collection).call

              collection.workspace_signals.delete_all

              signals.each_with_index do |attributes, index|
                collection.workspace_signals.create!(
                  attributes.merge(
                    position: index
                  )
                )
              end

              collection.workspace_signals.ordered
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end
