module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class PortfolioDashboard
            def initialize(scope = ResearchCollection.all)
              @scope = scope
            end

            def call
              collections = scope
                              .prioritized
                              .to_a

              {
                totals: totals(collections),
                collections: collections.map do |collection|
                  collection_row(collection)
                end
              }
            end

            private

            attr_reader :scope

            def totals(collections)
              {
                collections: collections.length,
                open_questions: collections.sum(&:open_questions_count),
                findings: collections.sum do |collection|
                  collection.findings.active.count
                end,
                relationships: collections.sum do |collection|
                  collection.relationships.active.count
                end,
                snapshots: collections.sum(&:snapshot_count)
              }
            end

            def collection_row(collection)
              {
                id: collection.id,
                name: collection.try(:name),
                status: collection.try(:status),
                priority: collection.try(:priority),
                health: collection.portfolio_health,
                questions: collection.open_questions_count,
                findings: collection.findings.active.count,
                workspaces: EvidenceInventory
                              .new(collection)
                              .call[:total_workspaces]
              }
            end
          end
        end
      end
    end
  end
end
