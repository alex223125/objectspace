
# app/services/admin/ecosystems/load_sources/entities/entity_relationship/relationship_evidence_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipEvidenceService
            Relationship =
              ::Ecosystems::LoadSources::Entity::EntityRelationship

            def initialize(relationship_id:)
              @relationship_id = Integer(relationship_id)
            end

            def call
              relationship = Relationship.unscoped.find(@relationship_id)
              evidence = relationship.evidence

              {
                relationship_id: relationship.id,
                state: relationship.state,
                confidence: relationship.confidence,
                evidence_present: evidence.present?,
                evidence_type: evidence.class.name,
                evidence_items: normalize_evidence(evidence)
              }
            end

            private

            def normalize_evidence(evidence)
              case evidence
              when Array
                evidence.first(100)
              when Hash
                evidence.map do |key, value|
                  { key: key.to_s, value: value }
                end.first(100)
              when String
                evidence.present? ? [{ value: evidence.first(5_000) }] : []
              else
                []
              end
            end
          end
        end
      end
    end
  end
end