# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipIntelligenceService

            DEFAULT_LIMIT = 30

            def initialize(entity, limit: DEFAULT_LIMIT)
              @entity = entity
              @limit = limit.to_i.clamp(1, 100)
            end

            def call
              relationships =
                relationship_scope
                  .includes(:source_entity, :target_entity)
                  .order(confidence: :desc)
                  .limit(limit)
                  .to_a

              neighbors =
                relationships.filter_map do |relationship|
                  relationship.other_entity_for(entity)
                end

              {
                entity: entity_payload,
                metrics: metrics(relationships),
                relationships:
                  relationships.map do |relationship|
                    relationship_payload(
                      relationship
                    )
                  end,
                nodes:
                  nodes_payload(neighbors),
                edges:
                  edges_payload(relationships)
              }
            end

            private

            attr_reader :entity, :limit

            def relationship_scope
              self.class.relationship_class
                  .where(
                    "source_entity_id = :id OR target_entity_id = :id",
                    id: entity.id
                  )
                  .where.not(state: "rejected")
            end

            def metrics(relationships)
              confidences =
                relationships.map do |relationship|
                  relationship.confidence.to_f
                end

              {
                total_relationships:
                  relationships.length,

                confirmed_relationships:
                  relationships.count(&:confirmed?),

                suggested_relationships:
                  relationships.count(&:suggested?),

                high_confidence_relationships:
                  relationships.count do |relationship|
                    relationship.confidence.to_f >= 0.70
                  end,

                average_confidence:
                  if confidences.empty?
                    0.0
                  else
                    (
                      confidences.sum /
                        confidences.length
                    ).round(4)
                  end,

                average_confidence_percent:
                  if confidences.empty?
                    0
                  else
                    (
                      confidences.sum /
                        confidences.length *
                        100
                    ).round
                  end
              }
            end

            def entity_payload
              {
                id: entity.id,
                name: entity.name,
                slug: entity.slug,
                summary: entity.summary,
                scope: entity.scope,
                status: entity.status,
                health_score:
                  entity.respond_to?(:health_score) ?
                    entity.health_score :
                    nil
              }
            end

            def relationship_payload(relationship)
              other =
                relationship.other_entity_for(
                  entity
                )

              {
                id: relationship.id,
                entity_id: other&.id,
                entity_name: other&.name,
                entity_slug: other&.slug,
                relationship_kind:
                  relationship.relationship_kind,
                relationship_label:
                  relationship.label,
                confidence:
                  relationship.confidence.to_f.round(4),
                confidence_percent:
                  relationship.confidence_percent,
                state: relationship.state,
                evidence:
                  Array(relationship.evidence),
                evidence_count:
                  relationship.evidence_count
              }
            end

            def nodes_payload(neighbors)
              all =
                [entity] + neighbors

              all
                .compact
                .uniq { |record| record.id }
                .map do |record|
                {
                  id: record.id,
                  name: record.name,
                  slug: record.slug,
                  scope: record.scope,
                  status: record.status,
                  health_score:
                    record.respond_to?(:health_score) ?
                      record.health_score :
                      nil
                }
              end
            end

            def edges_payload(relationships)
              relationships.map do |relationship|
                {
                  id: relationship.id,
                  source:
                    relationship.source_entity_id,
                  target:
                    relationship.target_entity_id,
                  kind:
                    relationship.relationship_kind,
                  confidence:
                    relationship.confidence.to_f,
                  state:
                    relationship.state
                }
              end
            end

            def self.relationship_class
              Ecosystems::LoadSources::Entity::EntityRelationship
            end

          end
        end
      end
    end
  end
end