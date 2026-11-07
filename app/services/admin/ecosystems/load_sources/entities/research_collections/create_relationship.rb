module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class CreateRelationship
            def initialize(collection:, attributes:)
              @collection = collection
              @attributes = attributes.to_h.symbolize_keys
            end

            def call
              relationship = collection.investigation_relationships.new(
                attributes.slice(
                  :source_workspace_id,
                  :target_workspace_id,
                  :relationship_type,
                  :status,
                  :label,
                  :description,
                  :confidence,
                  :position
                )
              )

              relationship.save
              relationship
            end

            private

            attr_reader :collection, :attributes
          end
        end
      end
    end
  end
end