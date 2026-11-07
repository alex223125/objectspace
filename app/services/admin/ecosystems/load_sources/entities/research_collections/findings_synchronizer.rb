module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class FindingsSynchronizer
            def initialize(collection)
              @collection = collection
            end

            def call
              signals = collection.workspace_signals
                                  .where(signal_type: %w[evidence anomaly observation])
                                  .ordered

              signals.each_with_index do |signal, index|
                existing = collection.findings.find_by(
                  title: signal.title,
                  statement: signal.statement
                )

                next if existing

                collection.findings.create!(
                  title: signal.title,
                  statement: signal.statement,
                  confidence: signal.confidence,
                  status: "active",
                  position: index
                )
              end

              collection.findings.active.ordered
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end