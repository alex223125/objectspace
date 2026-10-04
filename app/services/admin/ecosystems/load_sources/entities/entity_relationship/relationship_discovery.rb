# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class RelationshipDiscovery

        MIN_CONFIDENCE = 0.35

        STOP_WORDS = %w[
          the
          a
          an
          and
          or
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
          was
          were
          be
          this
          that
          these
          those
          entity
          entities
        ].freeze

        attr_reader :entity

        def initialize(entity)
          @entity = entity
        end

        def call(limit: 50)
          candidates =
            Ecosystems::LoadSources::Entity::Entity
              .where.not(id: entity.id)
              .includes(
                :entity_type,
                :entity_template
              )

          scored =
            candidates.filter_map do |candidate|
              result =
                score_candidate(candidate)

              next if result[:confidence] < MIN_CONFIDENCE

              result
            end

          scored
            .sort_by { |result| -result[:confidence] }
            .first(limit)
        end

        private

        def score_candidate(candidate)
          signals = []

          if same_entity_type?(candidate)
            signals << {
              type: "shared_entity_type",
              weight: 0.20,
              description: "Both entities use the same entity type."
            }
          end

          if same_entity_template?(candidate)
            signals << {
              type: "shared_entity_template",
              weight: 0.15,
              description: "Both entities use the same entity template."
            }
          end

          if same_scope?(candidate)
            signals << {
              type: "shared_scope",
              weight: 0.10,
              description: "Both entities have the same ontology scope."
            }
          end

          shared_terms =
            shared_terms_with(candidate)

          if shared_terms.any?
            term_weight =
              [
                shared_terms.length * 0.05,
                0.30
              ].min

            signals << {
              type: "shared_terms",
              weight: term_weight,
              terms: shared_terms,
              description:
                "Entity names and summaries share meaningful terms."
            }
          end

          name_similarity =
            text_similarity(
              entity.name,
              candidate.name
            )

          if name_similarity >= 0.50
            signals << {
              type: "name_similarity",
              weight: name_similarity * 0.20,
              score: name_similarity.round(4),
              description:
                "Entity names are textually similar."
            }
          end

          summary_similarity =
            text_similarity(
              entity.summary,
              candidate.summary
            )

          if summary_similarity >= 0.40
            signals << {
              type: "summary_similarity",
              weight: summary_similarity * 0.15,
              score: summary_similarity.round(4),
              description:
                "Entity summaries are textually similar."
            }
          end

          confidence =
            [
              signals.sum { |signal| signal[:weight] },
              1.0
            ].min.round(4)

          {
            source_entity_id: entity.id,
            target_entity_id: candidate.id,
            relationship_kind:
              relationship_kind_for(signals),
            confidence: confidence,
            evidence: signals
          }
        end

        def same_entity_type?(candidate)
          entity.entity_type_id.present? &&
            candidate.entity_type_id.present? &&
            entity.entity_type_id == candidate.entity_type_id
        end

        def same_entity_template?(candidate)
          entity.entity_template_id.present? &&
            candidate.entity_template_id.present? &&
            entity.entity_template_id ==
              candidate.entity_template_id
        end

        def same_scope?(candidate)
          entity.scope.present? &&
            candidate.scope.present? &&
            entity.scope == candidate.scope
        end

        def shared_terms_with(candidate)
          left =
            meaningful_terms(
              "#{entity.name} #{entity.summary}"
            )

          right =
            meaningful_terms(
              "#{candidate.name} #{candidate.summary}"
            )

          (left & right).first(10)
        end

        def meaningful_terms(value)
          value.to_s
               .downcase
               .gsub(/[^a-z0-9_\- ]/, " ")
               .split
               .reject { |word| word.length < 3 }
               .reject { |word| STOP_WORDS.include?(word) }
               .uniq
        end

        def text_similarity(left, right)
          left_terms =
            meaningful_terms(left)

          right_terms =
            meaningful_terms(right)

          return 0.0 if left_terms.empty?
          return 0.0 if right_terms.empty?

          intersection =
            (left_terms & right_terms).length.to_f

          union =
            (left_terms | right_terms).length.to_f

          return 0.0 if union.zero?

          intersection / union
        end

        def relationship_kind_for(signals)
          types =
            signals.map { |signal| signal[:type] }

          return "semantic" if
            types.include?("shared_terms") ||
              types.include?("summary_similarity")

          return "structural" if
            types.include?("shared_entity_type") ||
              types.include?("shared_entity_template")

          return "contextual" if
            types.include?("shared_scope")

          "related"
        end

      end

    end
  end
end