# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipDiscoveryService

            MINIMUM_CONFIDENCE = 0.45

            STOP_WORDS = %w[
          the
          a
          an
          and
          or
          of
          to
          for
          in
          on
          with
          from
          by
          is
          are
          this
          that
          entity
          system
          data
        ].freeze

            def initialize(
              entity_scope: nil,
              limit: 500
            )
              @entity_scope =
                entity_scope ||
                  entity_model.all

              @limit = limit.to_i.clamp(1, 5_000)
            end

            def call
              entities =
                @entity_scope
                  .includes(:entity_type, :entity_template)
                  .limit(@limit)
                  .to_a

              created = 0
              updated = 0

              entities.each_with_index do |source, index|

                entities[(index + 1)..].to_a.each do |target|

                  score =
                    score_pair(source, target)

                  next if score[:confidence] < MINIMUM_CONFIDENCE

                  relationship =
                    relationship_model.find_or_initialize_by(
                      source_entity_id: [
                        source.id,
                        target.id
                      ].min,
                      target_entity_id: [
                        source.id,
                        target.id
                      ].max
                    )

                  was_new = relationship.new_record?

                  relationship.relationship_kind =
                    "related"

                  relationship.confidence =
                    score[:confidence]

                  relationship.state =
                    if relationship.state_confirmed?
                      "confirmed"
                    else
                      "suggested"
                    end

                  relationship.evidence =
                    score[:evidence]

                  relationship.last_discovered_at =
                    Time.current

                  relationship.save!

                  if was_new
                    created += 1
                  else
                    updated += 1
                  end

                end
              end

              {
                processed_entities: entities.length,
                created: created,
                updated: updated
              }
            end

            private

            def entity_model
              Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_model
              Ecosystems::LoadSources::Entity::EntityRelationship
            end

            def score_pair(source, target)
              confidence = 0.0
              evidence = []

              if source.entity_type_id.present? &&
                source.entity_type_id == target.entity_type_id

                confidence += 0.20

                evidence << {
                  type: "shared_entity_type",
                  value: source.entity_type&.name
                }
              end

              if source.entity_template_id.present? &&
                source.entity_template_id == target.entity_template_id

                confidence += 0.15

                evidence << {
                  type: "shared_entity_template",
                  value: source.entity_template&.name
                }
              end

              if source.scope.present? &&
                source.scope == target.scope

                confidence += 0.10

                evidence << {
                  type: "shared_scope",
                  value: source.scope
                }
              end

              shared_name_tokens =
                shared_tokens(
                  source.name,
                  target.name
                )

              unless shared_name_tokens.empty?

                confidence +=
                  [shared_name_tokens.length * 0.10, 0.30].min

                evidence << {
                  type: "shared_name_terms",
                  value: shared_name_tokens
                }
              end

              shared_summary_tokens =
                shared_tokens(
                  source.summary,
                  target.summary
                )

              unless shared_summary_tokens.empty?

                confidence +=
                  [shared_summary_tokens.length * 0.05, 0.20].min

                evidence << {
                  type: "shared_summary_terms",
                  value: shared_summary_tokens.first(10)
                }
              end

              {
                confidence: confidence.clamp(0.0, 1.0).round(4),
                evidence: evidence
              }
            end

            def shared_tokens(left, right)
              left_tokens = tokenize(left)
              right_tokens = tokenize(right)

              (left_tokens & right_tokens)
                .sort
                .first(10)
            end

            def tokenize(value)
              value
                .to_s
                .downcase
                .gsub(/[^a-z0-9\s]/, " ")
                .split
                .reject { |token| token.length < 3 }
                .reject { |token| STOP_WORDS.include?(token) }
                .uniq
            end

          end
        end
      end
    end
  end
end