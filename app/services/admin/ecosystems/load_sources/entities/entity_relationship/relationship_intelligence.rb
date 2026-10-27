# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipIntelligence

            DEFAULT_LIMIT = 12

            def initialize(entity,
                           limit: DEFAULT_LIMIT)

              @entity = entity
              @limit = limit
            end

            def call
              {
                entity: entity,
                relationships: relationships,
                related_entities: related_entities,
                signals: signals,
                statistics: statistics
              }
            end

            private

            attr_reader :entity,
                        :limit

            def relationship_scope
              EntityRelationship
                .for_entity(entity.id)
                .active
                .includes(
                  :source_entity,
                  :target_entity
                )
            end

            def relationships
              relationship_scope
                .ordered_by_confidence
                .limit(limit)
            end

            def related_entities
              relationships.filter_map do |relationship|
                relationship.other_entity(entity)
              end
            end

            def statistics
              scope =
                relationship_scope

              {
                total: scope.count,

                strong:
                  scope
                    .where("confidence >= ?", 0.70)
                    .count,

                medium:
                  scope
                    .where(
                      "confidence >= ? AND confidence < ?",
                      0.45,
                      0.70
                    )
                    .count,

                suggested:
                  scope
                    .where(
                      state:
                        EntityRelationship.states[:suggested]
                    )
                    .count,

                confirmed:
                  scope
                    .where(
                      state:
                        EntityRelationship.states[:confirmed]
                    )
                    .count,

                average_confidence:
                  scope.average(:confidence).to_f.round(4)
              }
            end

            def signals
              signal_counts = Hash.new(0)

              relationships.each do |relationship|
                relationship.evidence_items.each do |evidence|
                  signal =
                    evidence["signal"] ||
                      evidence[:signal]

                  signal_counts[signal.to_s] += 1
                end
              end

              signal_counts
                .sort_by { |_key, count| -count }
                .first(6)
                .to_h
            end

          end
        end
      end
    end
  end
end