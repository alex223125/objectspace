# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipDiscoveryPersistence

            def initialize(entity)
              @entity = entity
            end

            def call(limit: 50)
              discoveries =
                RelationshipDiscovery
                  .new(@entity)
                  .call(limit: limit)

              persisted = []

              discoveries.each do |discovery|
                relationship =
                  find_or_initialize_relationship(
                    discovery
                  )

                next if relationship.state_confirmed?

                relationship.relationship_kind =
                  discovery[:relationship_kind]

                relationship.confidence =
                  discovery[:confidence]

                relationship.evidence =
                  discovery[:evidence]

                relationship.state =
                  "suggested"

                relationship.last_discovered_at =
                  Time.current

                relationship.save!

                persisted << relationship
              end

              persisted
            end

            private

            def find_or_initialize_relationship(discovery)
              EntityRelationship.find_or_initialize_by(
                source_entity_id:
                  discovery[:source_entity_id],
                target_entity_id:
                  discovery[:target_entity_id]
              )
            end

          end
        end
      end
    end
  end
end