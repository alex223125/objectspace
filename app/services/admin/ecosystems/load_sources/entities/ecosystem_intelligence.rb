# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EcosystemIntelligence

        def self.call(entity:, limit: 20)
          new(
            entity: entity,
            limit: limit
          ).call
        end

        def initialize(entity:, limit:)
          @entity = entity
          @limit = limit.to_i.clamp(1, 100)
        end

        def call
          relationships =
            EntityRelationship
              .visible
              .where(
                "source_entity_id = :id OR target_entity_id = :id",
                id: @entity.id
              )
              .includes(
                :source_entity,
                :target_entity
              )
              .ordered_by_confidence
              .limit(@limit)
              .to_a

          neighbors =
            relationships.filter_map do |relationship|
              other =
                relationship.other_entity_for(
                  @entity
                )

              next unless other

              {
                entity: other,
                relationship: relationship,
                direction:
                  relationship.direction_from(
                    @entity
                  )
              }
            end

          {
            entity: @entity,
            relationship_count: relationships.length,
            neighbor_count: neighbors.length,
            confirmed_count:
              relationships.count(&:state_confirmed?),
            strong_count:
              relationships.count(&:strong?),
            average_confidence:
              average_confidence(relationships),
            ecosystem_score:
              ecosystem_score(relationships),
            attention_signals:
              attention_signals(
                relationships,
                neighbors
              ),
            neighbors: neighbors
          }
        end

        private

        def average_confidence(relationships)
          return 0 if relationships.empty?

          (
            relationships.sum do |relationship|
              relationship.confidence.to_f
            end /
              relationships.length
          ).round(3)
        end

        def ecosystem_score(relationships)
          return 0 if relationships.empty?

          weighted =
            relationships.sum do |relationship|
              relationship.intelligence_weight
            end

          (
            weighted /
              relationships.length *
              100
          ).round
        end

        def attention_signals(relationships, neighbors)
          signals = []

          if relationships.empty?
            signals << {
              key: :isolated,
              severity: :high,
              label: "Isolated entity",
              message:
                "No ecosystem relationships have been discovered."
            }
          end

          weak_count =
            relationships.count(&:weak?)

          if weak_count.positive?
            signals << {
              key: :weak_relationships,
              severity: :medium,
              label: "Weak relationship confidence",
              message:
                "#{weak_count} relationship(s) need stronger evidence."
            }
          end

          if neighbors.length >= 8
            signals << {
              key: :high_connectivity,
              severity: :info,
              label: "Highly connected",
              message:
                "This entity sits inside a dense ecosystem cluster."
            }
          end

          unless relationships.any?(&:state_confirmed?)
            signals << {
              key: :unconfirmed,
              severity: :medium,
              label: "Relationships need review",
              message:
                "No discovered relationship has been confirmed yet."
            }
          end

          signals
        end

      end

    end
  end
end