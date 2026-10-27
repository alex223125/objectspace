# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipScore
            STOP_WORDS =
              ::Admin::Ecosystems::LoadSources::Entities::
                  EntityRelationship::RelationshipDiscovery::STOP_WORDS

            def initialize(source, target)
              @source = source
              @target = target
            end

            def call
              signals = []

              signals << 0.25 if same_entity_type?
              signals << 0.20 if same_template?
              signals << 0.10 if same_scope?

              name_similarity =
                token_similarity(
                  source.name,
                  target.name
                )

              summary_similarity =
                token_similarity(
                  source.summary,
                  target.summary
                )

              slug_similarity =
                token_similarity(
                  source.slug,
                  target.slug
                )

              signals << name_similarity * 0.30
              signals << summary_similarity * 0.10
              signals << slug_similarity * 0.05

              confidence =
                signals.sum.clamp(0.0, 1.0).round(3)

              {
                confidence: confidence,
                relationship_kind:
                  relationship_kind(confidence),
                evidence:
                  build_evidence(
                    name_similarity,
                    summary_similarity,
                    slug_similarity
                  )
              }
            end

            private

            attr_reader :source, :target

            def same_entity_type?
              source.entity_type_id.present? &&
                target.entity_type_id.present? &&
                source.entity_type_id ==
                  target.entity_type_id
            end

            def same_template?
              source.entity_template_id.present? &&
                target.entity_template_id.present? &&
                source.entity_template_id ==
                  target.entity_template_id
            end

            def same_scope?
              source.scope.present? &&
                target.scope.present? &&
                source.scope == target.scope
            end

            def token_similarity(first, second)
              first_tokens =
                tokens(first)

              second_tokens =
                tokens(second)

              return 0.0 if first_tokens.empty?
              return 0.0 if second_tokens.empty?

              intersection =
                (
                  first_tokens &
                    second_tokens
                ).length

              union =
                (
                  first_tokens |
                    second_tokens
                ).length

              return 0.0 if union.zero?

              intersection.to_f / union
            end

            def tokens(value)
              value.to_s
                   .downcase
                   .gsub(/[^a-z0-9_\- ]/, " ")
                   .split
                   .map(&:strip)
                   .reject(&:blank?)
                   .reject do |token|
                STOP_WORDS.include?(token)
              end
                   .uniq
            end

            def relationship_kind(confidence)
              if confidence >= 0.80
                "strongly_related"
              elsif confidence >= 0.65
                "related"
              else
                "possibly_related"
              end
            end

            def build_evidence(
              name_similarity,
              summary_similarity,
              slug_similarity
            )
              evidence = []

              if source.entity_type_id ==
                target.entity_type_id &&
                source.entity_type_id.present?

                evidence << {
                  "signal" => "shared_entity_type",
                  "weight" => 0.25
                }
              end

              if source.entity_template_id ==
                target.entity_template_id &&
                source.entity_template_id.present?

                evidence << {
                  "signal" => "shared_entity_template",
                  "weight" => 0.20
                }
              end

              if source.scope.present? &&
                source.scope == target.scope

                evidence << {
                  "signal" => "shared_scope",
                  "weight" => 0.10
                }
              end

              if name_similarity.positive?
                evidence << {
                  "signal" => "name_token_similarity",
                  "score" => name_similarity.round(3)
                }
              end

              if summary_similarity.positive?
                evidence << {
                  "signal" => "summary_token_similarity",
                  "score" => summary_similarity.round(3)
                }
              end

              if slug_similarity.positive?
                evidence << {
                  "signal" => "slug_similarity",
                  "score" => slug_similarity.round(3)
                }
              end

              evidence
            end
          end
        end
      end
    end
  end
end
