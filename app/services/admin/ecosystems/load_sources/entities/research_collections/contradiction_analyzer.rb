module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class ContradictionAnalyzer
            def initialize(collection)
              @collection = collection
            end

            def call
              collection.relationships
                        .active
                        .where(relationship_type: "contradicts")
                        .map do |relationship|
                {
                  id: relationship.id,
                  source_workspace_id: relationship.source_workspace_id,
                  target_workspace_id: relationship.target_workspace_id,
                  confidence: relationship.confidence,
                  note: relationship.note
                }
              end
            end
          end
        end
      end
    end
  end
end
