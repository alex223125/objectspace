# frozen_string_literal: true

module Ecosystems
  module LoadSources

    class EntityIntelligence

      def initialize(entity)
        @entity = entity
      end

      def call
        {
          entity: entity_payload,
          relationships: relationship_payload,
          signals: signals,
          score: intelligence_score
        }
      end

      private

      attr_reader :entity

      def relationship_scope
        Ecosystems::LoadSources::Entity::EntityRelationship
      end

      def entity_scope
        Ecosystems::LoadSources::Entity::Entity
      end

      def relationships
        @relationships ||=
          relationship_scope
            .active
            .where(
              "source_entity_id = :id OR target_entity_id = :id",
              id: entity.id
            )
            .includes(
              :source_entity,
              :target_entity
            )
            .order(confidence: :desc)
            .limit(25)
      end

      def related_entities
        relationships.map do |relationship|
          if relationship.source_entity_id == entity.id
            relationship.target_entity
          else
            relationship.source_entity
          end
        end.compact.uniq
      end

      def entity_payload
        {
          id: entity.id,
          name: entity.name,
          slug: entity.slug,
          scope: entity.scope,
          status: entity.status,
          workflow_state:
            entity.respond_to?(:workflow_state) ?
              entity.workflow_state :
              nil,
          health_score:
            entity.respond_to?(:health_score) ?
              entity.health_score :
              nil
        }
      end

      def relationship_payload
        relationships.map do |relationship|
          related =
            if relationship.source_entity_id == entity.id
              relationship.target_entity
            else
              relationship.source_entity
            end

          {
            id: relationship.id,
            entity_id: related&.id,
            entity_name: related&.name,
            relationship_kind:
              relationship.relationship_kind,
            confidence:
              relationship.confidence.to_f,
            confidence_percent:
              relationship.confidence_percent,
            state: relationship.state,
            evidence:
              relationship.evidence_items
          }
        end
      end

      def signals
        result = []

        if relationships.empty?
          result << {
            key: "isolated",
            severity: "attention",
            title: "No ecosystem relationships",
            message:
              "This entity currently has no discovered relationships."
          }
        end

        if relationships.any? &&
          relationships.count >= 8

          result << {
            key: "high_connectivity",
            severity: "positive",
            title: "Highly connected entity",
            message:
              "This entity participates in a dense relationship cluster."
          }
        end

        if relationships.any? &&
          relationships.first.confidence.to_f >= 0.80

          result << {
            key: "strong_relationship",
            severity: "positive",
            title: "Strong relationship detected",
            message:
              "At least one relationship has high discovery confidence."
          }
        end

        if entity.respond_to?(:health_score) &&
          entity.health_score < 50

          result << {
            key: "health_risk",
            severity: "critical",
            title: "Entity health requires attention",
            message:
              "The entity has a low structural health score."
          }
        end

        result
      end

      def intelligence_score
        relationship_score =
          if relationships.empty?
            0
          else
            (
              relationships.sum do |relationship|
                relationship.confidence.to_f
              end /
                relationships.length *
                100
            ).round
          end

        health_score =
          if entity.respond_to?(:health_score)
            entity.health_score.to_i
          else
            0
          end

        (
          relationship_score * 0.60 +
            health_score * 0.40
        ).round
      end

    end

  end
end