# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class EntityRelationshipDiscovery

            DEFAULT_LIMIT = 250
            DEFAULT_THRESHOLD = 0.45

            STOP_WORDS = %w[
        the
        and
        or
        a
        an
        of
        to
        in
        on
        for
        with
        from
        by
        is
        are
        be
        as
        at
        this
        that
        these
        those
        entity
        system
        type
        information
        data
      ].freeze

            def initialize(
              entity:,
              limit: DEFAULT_LIMIT,
              threshold: DEFAULT_THRESHOLD
            )
              @entity = entity
              @limit = limit.to_i.clamp(1, 1_000)
              @threshold = threshold.to_f.clamp(0.0, 1.0)
            end

            def call
              candidates.find_each(batch_size: 100) do |candidate|
                score = score_candidate(candidate)

                next if score[:confidence] < @threshold

                persist_relationship(candidate, score)
              end

              true
            end

            private

            attr_reader :entity, :limit, :threshold

            def entity_scope
              Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_scope
              Ecosystems::LoadSources::Entity::EntityRelationship
            end

            def candidates
              scope = entity_scope
                        .where.not(id: entity.id)
                        .where(
                          "entity_type_id = :type_id
                    OR entity_template_id = :template_id
                    OR scope = :scope",
                          type_id: entity.entity_type_id,
                          template_id: entity.entity_template_id,
                          scope: entity.scope
                        )

              scope
                .includes(:entity_type, :entity_template)
                .limit(limit)
            end

            def score_candidate(candidate)
              evidence = []
              score = 0.0

              if entity.entity_type_id.present? &&
                entity.entity_type_id == candidate.entity_type_id

                score += 0.25

                evidence << {
                  signal: "shared_entity_type",
                  weight: 0.25,
                  value: entity.entity_type&.name
                }
              end

              if entity.entity_template_id.present? &&
                entity.entity_template_id == candidate.entity_template_id

                score += 0.20

                evidence << {
                  signal: "shared_template",
                  weight: 0.20,
                  value: entity.entity_template&.name
                }
              end

              if entity.scope.present? &&
                entity.scope == candidate.scope

                score += 0.10

                evidence << {
                  signal: "shared_scope",
                  weight: 0.10,
                  value: entity.scope
                }
              end

              text_score =
                textual_similarity(candidate)

              if text_score.positive?
                weighted_text_score =
                  text_score * 0.45

                score += weighted_text_score

                evidence << {
                  signal: "textual_similarity",
                  weight: weighted_text_score.round(4),
                  value: text_score.round(4)
                }
              end

              name_score =
                name_similarity(candidate)

              if name_score >= 0.30
                weighted_name_score =
                  name_score * 0.20

                score += weighted_name_score

                evidence << {
                  signal: "name_similarity",
                  weight: weighted_name_score.round(4),
                  value: name_score.round(4)
                }
              end

              confidence =
                [score, 1.0].min.round(4)

              relationship_kind =
                strongest_relationship_kind(evidence)

              {
                confidence: confidence,
                relationship_kind: relationship_kind,
                evidence: evidence
              }
            end

            def textual_similarity(candidate)
              left =
                tokenize(
                  [
                    entity.name,
                    entity.slug,
                    entity.summary
                  ].compact.join(" ")
                )

              right =
                tokenize(
                  [
                    candidate.name,
                    candidate.slug,
                    candidate.summary
                  ].compact.join(" ")
                )

              return 0.0 if left.empty? || right.empty?

              intersection =
                (left & right).length.to_f

              union =
                (left | right).length.to_f

              return 0.0 if union.zero?

              intersection / union
            end

            def name_similarity(candidate)
              left =
                tokenize(entity.name.to_s)

              right =
                tokenize(candidate.name.to_s)

              return 0.0 if left.empty? || right.empty?

              intersection =
                (left & right).length.to_f

              denominator =
                [left.length, right.length].max.to_f

              return 0.0 if denominator.zero?

              intersection / denominator
            end

            def tokenize(value)
              value
                .to_s
                .downcase
                .gsub(/[^a-z0-9\s_-]/, " ")
                .split(/[\s_-]+/)
                .reject { |token| token.length < 3 }
                .reject { |token| STOP_WORDS.include?(token) }
                .uniq
            end

            def strongest_relationship_kind(evidence)
              return "related" if evidence.empty?

              signals =
                evidence.map { |item| item[:signal] }

              return "same_type" if signals.include?("shared_entity_type")
              return "same_template" if signals.include?("shared_template")
              return "same_scope" if signals.include?("shared_scope")
              return "semantic_similarity" if signals.include?("textual_similarity")

              "related"
            end

            def persist_relationship(candidate, score)
              source_id, target_id =
                canonical_pair(
                  entity.id,
                  candidate.id
                )

              relationship =
                relationship_scope.find_or_initialize_by(
                  source_entity_id: source_id,
                  target_entity_id: target_id
                )

              relationship.relationship_kind =
                score[:relationship_kind]

              relationship.confidence =
                score[:confidence]

              relationship.evidence =
                score[:evidence]

              relationship.last_discovered_at =
                Time.current

              relationship.state =
                "suggested" if relationship.new_record?

              relationship.save!
            end

            def canonical_pair(left_id, right_id)
              if left_id.to_i < right_id.to_i
                [left_id, right_id]
              else
                [right_id, left_id]
              end
            end

          end
        end
      end
    end
  end
end