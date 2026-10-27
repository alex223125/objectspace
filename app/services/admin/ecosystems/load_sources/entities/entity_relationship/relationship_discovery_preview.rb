# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipDiscoveryPreview

            def self.call(
              entities: nil,
              entity: nil,
              limit: 100,
              candidate_limit: 50
            )
              new(
                entities: entities,
                entity: entity,
                limit: limit,
                candidate_limit: candidate_limit
              ).call
            end

            def initialize(
              entities:,
              entity:,
              limit:,
              candidate_limit:
            )
              @entities = entities
              @entity = entity
              @limit = limit
              @candidate_limit = candidate_limit
            end

            def call
              result =
                RelationshipDiscovery.call(
                  entities: @entities,
                  entity: @entity,
                  limit: @limit,
                  candidate_limit: @candidate_limit
                )

              {
                entity_count:
                  result[:entity_count],

                candidate_count:
                  result[:candidate_count],

                candidates:
                  result[:candidates].map do |candidate|
                    {
                      source_entity_id:
                        candidate.source_id,

                      target_entity_id:
                        candidate.target_id,

                      source_name:
                        candidate.source.name,

                      target_name:
                        candidate.target.name,

                      relationship_kind:
                        candidate.relationship_kind,

                      confidence:
                        candidate.confidence,

                      confidence_percent:
                        (
                          candidate.confidence * 100
                        ).round,

                      evidence:
                        candidate.evidence
                    }
                  end
              }
            end

          end
        end
      end
    end
  end
end