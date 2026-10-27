# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipDiscovery
            DEFAULT_LIMIT = 100
            DEFAULT_CANDIDATE_LIMIT = 250
            MIN_CONFIDENCE = 0.45

            TEXT_FIELDS = %w[
      name
      slug
      summary
      description
    ].freeze

            STOP_WORDS = %w[
      the and or for with from into this that these those
      entity entities source system data information
    ].freeze

            RelationshipCandidate = Struct.new(
              :source,
              :target,
              :relationship_kind,
              :confidence,
              :evidence,
              keyword_init: true
            ) do
              def source_id
                source.id
              end

              def target_id
                target.id
              end
            end

            def self.call(
              entities: nil,
              entity: nil,
              limit: DEFAULT_LIMIT,
              candidate_limit: DEFAULT_CANDIDATE_LIMIT
            )
              new(
                entities: entities,
                entity: entity,
                limit: limit,
                candidate_limit: candidate_limit
              ).call
            end

            def initialize(
              entities: nil,
              entity: nil,
              limit: DEFAULT_LIMIT,
              candidate_limit: DEFAULT_CANDIDATE_LIMIT
            )
              @entity = entity
              @limit = limit.to_i.clamp(2, 500)
              @candidate_limit = candidate_limit.to_i.clamp(1, 2_000)

              @entities =
                if entity.present?
                  [entity]
                else
                  Array(entities).compact
                end
            end

            def call
              source_entities = load_entities
              candidates = discover_candidates(source_entities)
              persisted = persist_candidates(candidates)

              {
                entity_count: source_entities.length,
                candidate_count: candidates.length,
                persisted_count: persisted.length,
                candidates: candidates,
                relationships: persisted
              }
            end

            private

            def load_entities
              return @entities if @entities.any?

              Entity
                .order(:id)
                .limit(@limit)
                .to_a
            end

            def discover_candidates(entities)
              candidates = []

              entities.each_with_index do |source, index|
                entities[(index + 1)..].to_a.each do |target|
                  next if source.id == target.id

                  candidate = build_candidate(source, target)
                  next unless candidate
                  next if candidate.confidence < MIN_CONFIDENCE

                  candidates << candidate

                  break if candidates.length >= @candidate_limit
                end

                break if candidates.length >= @candidate_limit
              end

              candidates.sort_by do |candidate|
                [
                  -candidate.confidence,
                  candidate.source_id,
                  candidate.target_id
                ]
              end
            end

            def build_candidate(source, target)
              signals = [
                shared_scope_signal(source, target),
                shared_token_signal(source, target),
                explicit_reference_signal(source, target)
              ].compact

              return nil if signals.empty?

              RelationshipCandidate.new(
                source: source,
                target: target,
                relationship_kind: relationship_kind(signals),
                confidence: calculate_confidence(signals),
                evidence: build_evidence(signals)
              )
            end

            def shared_scope_signal(source, target)
              return unless source.respond_to?(:scope)
              return unless target.respond_to?(:scope)

              source_scope = normalize_text(source.scope)
              target_scope = normalize_text(target.scope)

              return if source_scope.blank? || target_scope.blank?
              return unless source_scope == target_scope

              {
                key: "shared_scope",
                weight: 0.25,
                message: "Both entities belong to the same scope.",
                data: {
                  source_scope: source.scope,
                  target_scope: target.scope
                }
              }
            end

            def shared_token_signal(source, target)
              source_tokens = entity_tokens(source)
              target_tokens = entity_tokens(target)

              return if source_tokens.empty? || target_tokens.empty?

              meaningful = source_tokens
                             .intersection(target_tokens)
                             .reject { |token| STOP_WORDS.include?(token) }

              return if meaningful.empty?

              {
                key: "shared_terms",
                weight: [0.10 + meaningful.length * 0.08, 0.35].min,
                message: "The entities share meaningful identifying terms.",
                data: { terms: meaningful.first(8) }
              }
            end

            def explicit_reference_signal(source, target)
              source_text = entity_text(source)

              matches = target_identifiers(target).select do |identifier|
                source_text.include?(identifier)
              end

              return if matches.empty?

              {
                key: "explicit_reference",
                weight: 0.45,
                message: "The source entity explicitly references the target entity.",
                data: { matched_identifiers: matches.first(5) }
              }
            end

            def calculate_confidence(signals)
              [signals.sum { |signal| signal[:weight].to_f }, 0.95].min.round(3)
            end

            def relationship_kind(_signals)
              "related"
            end

            def build_evidence(signals)
              signals.map do |signal|
                {
                  source: "relationship_discovery_v1",
                  signal: signal[:key],
                  message: signal[:message],
                  weight: signal[:weight],
                  data: signal[:data],
                  discovered_at: Time.current.iso8601
                }
              end
            end

            def persist_candidates(candidates)
              candidates.filter_map do |candidate|
                existing = find_existing_relationship(candidate)

                if existing
                  update_existing_relationship(existing, candidate)
                else
                  create_relationship(candidate)
                end
              end
            end

            def find_existing_relationship(candidate)
              EntityRelationship
                .where(relationship_kind: candidate.relationship_kind)
                .where(
                  "(source_entity_id = :source AND target_entity_id = :target) " \
                    "OR (source_entity_id = :target AND target_entity_id = :source)",
                  source: candidate.source_id,
                  target: candidate.target_id
                )
                .order(updated_at: :desc)
                .first
            end

            def update_existing_relationship(relationship, candidate)
              return relationship if relationship.state_rejected?
              return relationship if relationship.state_archived?

              relationship.assign_attributes(
                confidence: [
                  relationship.confidence.to_f,
                  candidate.confidence
                ].max.round(3),
                evidence: deduplicate_evidence(
                  Array(relationship.evidence) + Array(candidate.evidence)
                ),
                last_discovered_at: Time.current
              )

              relationship.save!
              relationship
            end

            def create_relationship(candidate)
              EntityRelationship.create!(
                source_entity_id: candidate.source_id,
                target_entity_id: candidate.target_id,
                relationship_kind: candidate.relationship_kind,
                confidence: candidate.confidence,
                state: "suggested",
                evidence: candidate.evidence,
                last_discovered_at: Time.current
              )
            end

            def deduplicate_evidence(evidence)
              evidence
                .uniq do |item|
                [
                  item["signal"] || item[:signal],
                  item["message"] || item[:message],
                  item["data"] || item[:data]
                ]
              end
                .last(20)
            end

            def entity_text(entity)
              TEXT_FIELDS.filter_map do |field|
                next unless entity.respond_to?(field)

                entity.public_send(field).to_s
              end.join(" ").downcase
            end

            def entity_tokens(entity)
              entity_text(entity).scan(/[a-z0-9]{3,}/).uniq
            end

            def target_identifiers(entity)
              identifiers = []

              identifiers << entity.slug if entity.respond_to?(:slug)
              identifiers << entity.name if entity.respond_to?(:name)

              identifiers
                .map { |identifier| normalize_text(identifier) }
                .reject(&:blank?)
                .uniq
            end

            def normalize_text(value)
              value.to_s.downcase.strip
            end
          end
        end
      end
    end
  end
end