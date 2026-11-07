module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class EvidenceManager
            def initialize(collection)
              @collection = collection
            end

            def create(attributes)
              @collection.evidence_references.create!(
                attributes.slice(
                  :research_workspace_id,
                  :source_type,
                  :title,
                  :description,
                  :source_url,
                  :external_identifier,
                  :confidence
                )
              )
            end

            def destroy(reference)
              return false unless reference.research_collection_id == @collection.id

              reference.destroy!
            end
          end
        end
      end
    end
  end
end
