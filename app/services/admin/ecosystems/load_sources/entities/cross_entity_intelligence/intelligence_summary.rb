# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module CrossEntityIntelligence
      class IntelligenceSummary
        def self.call(entity)
          new(entity).call
        end

        def initialize(entity)
          @entity = entity
        end

        def call
          relationships =
            Ecosystems::LoadSources::Entity::EntityRelationship
              .visible
              .for_entity(entity.id)
              .includes(
                :source_entity,
                :target_entity
              )

          {
            relationship_count: relationships.count,
            strong_relationship_count:
              relationships.count { |r| r.strength.to_i >= 60 },
            high_confidence_count:
              relationships.count { |r| r.confidence.to_f >= 70 },
            average_strength:
              average(relationships.map(&:strength)),
            average_confidence:
              average(relationships.map(&:confidence)),
            relationship_types:
              relationship_type_counts(relationships),
            attention_signals:
              attention_signals(relationships),
            top_relationships:
              top_relationships(relationships)
          }
        end

        private

        attr_reader :entity

        def average(values)
          return 0 if values.empty?

          (
            values.compact.map(&:to_f).sum /
              values.compact.length
          ).round
        end

        def relationship_type_counts(relationships)
          relationships
            .group_by(&:relationship_type)
            .transform_values(&:length)
        end

        def attention_signals(relationships)
          signals = []

          if relationships.empty?
            signals << {
              key: "no_relationships",
              level: "info",
              title: "No mapped relationships",
              message:
                "Run relationship discovery to identify nearby entities."
            }

            return signals
          end

          if relationships.count { |r| r.strength.to_i >= 80 } >= 3
            signals << {
              key: "dense_cluster",
              level: "attention",
              title: "Dense relationship cluster",
              message:
                "This entity is connected to several structurally similar entities."
            }
          end

          if relationships.any? { |r| r.confidence.to_f < 50 }
            signals << {
              key: "low_confidence",
              level: "review",
              title: "Low-confidence connections",
              message:
                "Some relationships should be reviewed before being treated as authoritative."
            }
          end

          if relationships.any? { |r| r.relationship_type == "shared_template" }
            signals << {
              key: "shared_template",
              level: "signal",
              title: "Shared template architecture",
              message:
                "One or more connected entities use the same template architecture."
            }
          end

          signals
        end

        def top_relationships(relationships)
          relationships
            .sort_by do |relationship|
            [
              -relationship.strength.to_i,
              -relationship.confidence.to_f
            ]
          end
            .first(8)
            .map do |relationship|
            other =
              relationship.other_entity(entity)

            {
              id: relationship.id,
              entity_id: other&.id,
              entity_name: other&.name,
              entity_slug: other&.slug,
              type: relationship.relationship_type,
              strength: relationship.strength.to_i,
              confidence: relationship.confidence.to_f
            }
          end
        end

      end

    end
  end
end