module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class RelationshipSynchronizer
            def initialize(collection)
              @collection = collection
            end

            def call
              detector = RelationshipDetector.new(collection)

              detector.call.each do |attributes|
                collection.relationships.find_or_create_by!(
                  source_workspace_id: attributes[:source_workspace].id,
                  target_workspace_id: attributes[:target_workspace].id
                ) do |relationship|
                  relationship.relationship_type =
                    attributes[:relationship_type]

                  relationship.confidence =
                    attributes[:confidence]

                  relationship.note =
                    attributes[:note]
                end
              end

              collection.relationships.active.ordered
            end

            private

            attr_reader :collection
          end
        end
      end
    end
  end
end