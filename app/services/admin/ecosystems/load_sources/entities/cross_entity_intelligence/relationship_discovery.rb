# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module CrossEntityIntelligence

      class RelationshipDiscovery

        DEFAULT_LIMIT = 40
        MINIMUM_SCORE = 35

        def self.call(entity, limit: DEFAULT_LIMIT)
          new(
            entity,
            limit: limit
          ).call
        end

        def initialize(entity, limit:)
          @entity = entity
          @limit = limit.to_i.clamp(1, 100)
        end

        def call
          return [] unless entity&.persisted?

          candidates = candidate_entities

          relationships = candidates.filter_map do |candidate|
            build_relationship(candidate)
          end

          persist_relationships(relationships)

          relationships
        end

        private

        attr_reader :entity, :limit

        def candidate_entities
          scope = entity.class
                        .where.not(id: entity.id)
                        .includes(
                          :entity_type,
                          :entity_template,
                          :entity_template_version
                        )

          scope = scope.where(
            "entity_type_id = :type_id OR entity_template_id = :template_id",
            type_id: entity.entity_type_id,
            template_id: entity.entity_template_id
          )

          scope
            .order(updated_at: :desc)
            .limit(limit)
        end

        def build_relationship(candidate)
          score = calculate_score(candidate)

          return if score < MINIMUM_SCORE

          signals = relationship_signals(candidate)

          {
            source_entity_id: [entity.id, candidate.id].min,
            target_entity_id: [entity.id, candidate.id].max,
            relationship_type: relationship_type_for(signals),
            confidence: score,
            strength: score,
            evidence: {
              "signals" => signals,
              "source_entity_id" => entity.id,
              "candidate_entity_id" => candidate.id,
              "calculated_at" => Time.current.iso8601
            }
          }
        end

        def persist_relationships(relationships)
          relationships.map do |attributes|
            relationship =
              Ecosystems::LoadSources::Entity::EntityRelationship
                .find_or_initialize_by(
                  source_entity_id: attributes[:source_entity_id],
                  target_entity_id: attributes[:target_entity_id],
                  relationship_type: attributes[:relationship_type]
                )

            relationship.assign_attributes(
              confidence: attributes[:confidence],
              strength: attributes[:strength],
              evidence: attributes[:evidence],
              status: "active",
              discovered_at: relationship.discovered_at || Time.current
            )

            relationship.save!

            relationship
          end
        end

        def calculate_score(candidate)
          score = 0

          score += 30 if same_entity_type?(candidate)
          score += 25 if same_template?(candidate)
          score += 10 if same_scope?(candidate)
          score += shared_text_score(candidate)
          score += 10 if temporal_overlap?(candidate)

          [score, 100].min
        end

        def relationship_signals(candidate)
          signals = []

          signals << "shared_entity_type" if same_entity_type?(candidate)
          signals << "shared_template" if same_template?(candidate)
          signals << "shared_scope" if same_scope?(candidate)

          shared =
            shared_concepts(candidate)

          if shared.any?
            signals << "shared_concepts:#{shared.join(',')}"
          end

          signals << "temporal_overlap" if temporal_overlap?(candidate)

          signals
        end

        def relationship_type_for(signals)
          return "shared_template" if signals.include?("shared_template")
          return "shared_type" if signals.include?("shared_entity_type")
          return "shared_concepts" if signals.any? { |s| s.start_with?("shared_concepts:") }
          return "temporal_overlap" if signals.include?("temporal_overlap")
          return "shared_scope" if signals.include?("shared_scope")

          "related"
        end

        def same_entity_type?(candidate)
          entity.entity_type_id.present? &&
            entity.entity_type_id == candidate.entity_type_id
        end

        def same_template?(candidate)
          entity.entity_template_id.present? &&
            entity.entity_template_id == candidate.entity_template_id
        end

        def same_scope?(candidate)
          entity.scope.present? &&
            candidate.scope.present? &&
            entity.scope == candidate.scope
        end

        def shared_text_score(candidate)
          shared = shared_concepts(candidate)

          case shared.length
          when 0
            0
          when 1
            8
          when 2
            14
          when 3
            18
          else
            25
          end
        end

        def shared_concepts(candidate)
          left =
            tokenize(
              [
                entity.name,
                entity.summary,
                entity.slug
              ].compact.join(" ")
            )

          right =
            tokenize(
              [
                candidate.name,
                candidate.summary,
                candidate.slug
              ].compact.join(" ")
            )

          (left & right).first(8)
        end

        def tokenize(value)
          value
            .to_s
            .downcase
            .gsub(/[^a-z0-9_\- ]/, " ")
            .split
            .reject { |token| token.length < 4 }
            .reject { |token| stop_words.include?(token) }
            .uniq
        end

        def stop_words
          @stop_words ||= %w[
            this that with from into their there about
            entity entities concept concepts real world
            draft published archived current latest
            data information system systems
            type template version
          ]
        end

        def temporal_overlap?(candidate)
          left_from = entity.valid_from
          left_until = entity.valid_until

          right_from = candidate.valid_from
          right_until = candidate.valid_until

          return false if left_from.blank? || right_from.blank?

          left_end = left_until || Time.current
          right_end = right_until || Time.current

          left_from <= right_end &&
            right_from <= left_end
        end

      end

    end
  end
end