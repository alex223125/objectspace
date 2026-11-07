# frozen_string_literal: true
module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class DiscoveryEngine
            DEFAULT_LIMIT = 8

            def initialize(entity = nil, limit: DEFAULT_LIMIT)
              @entity = entity
              @limit = limit.to_i.clamp(1, 50)
            end

            def call
              return empty_payload unless entity

              candidates = relationship_candidates

              {
                entity: entity_payload(entity),
                recommendations: candidates.first(limit).map do |candidate|
                  recommendation_payload(candidate)
                end,
                missions: build_missions(candidates),
                stats: stats(candidates)
              }
            end

            private

            attr_reader :entity, :limit

            def empty_payload
              {
                entity: nil,
                recommendations: [],
                missions: [],
                stats: {
                  candidates: 0,
                  strong_connections: 0,
                  medium_connections: 0,
                  weak_connections: 0
                }
              }
            end

            def relationship_candidates
              (outgoing_relationships + incoming_relationships)
                .filter_map do |relationship|
                candidate_from_relationship(relationship)
              end
                .reject do |candidate|
                candidate[:entity].id == entity.id
              end
                .uniq { |candidate| candidate[:entity].id }
                .sort_by { |candidate| -candidate[:score] }
            end

            def outgoing_relationships
              return [] unless entity.respond_to?(:outgoing_relationships)

              entity.outgoing_relationships
                    .includes(:target_entity)
                    .to_a
            rescue StandardError
              []
            end

            def incoming_relationships
              return [] unless entity.respond_to?(:incoming_relationships)

              entity.incoming_relationships
                    .includes(:source_entity)
                    .to_a
            rescue StandardError
              []
            end

            def candidate_from_relationship(relationship)
              target =
                relationship.target_entity if
                relationship.respond_to?(:target_entity)

              source =
                relationship.source_entity if
                relationship.respond_to?(:source_entity)

              candidate =
                if target.present? && target.id != entity.id
                  target
                elsif source.present? && source.id != entity.id
                  source
                end

              return unless candidate

              {
                entity: candidate,
                relationship: relationship,
                score: relationship_score(relationship),
                reasons: relationship_reasons(relationship)
              }
            end

            def relationship_score(relationship)
              score = 0

              if relationship.respond_to?(:confidence)
                score += relationship.confidence.to_f * 50
              end

              if relationship.respond_to?(:state) &&
                relationship.state.to_s == "confirmed"
                score += 20
              end

              if relationship.respond_to?(:relationship_kind) &&
                relationship.relationship_kind.present?
                score += 10
              end

              if relationship.respond_to?(:last_discovered_at) &&
                relationship.last_discovered_at.present? &&
                relationship.last_discovered_at >= 7.days.ago
                score += 10
              end

              score.round.clamp(0, 100)
            end

            def relationship_reasons(relationship)
              reasons = []

              if relationship.respond_to?(:relationship_kind) &&
                relationship.relationship_kind.present?
                reasons << "Relationship: #{relationship.relationship_kind}"
              end

              if relationship.respond_to?(:confidence) &&
                relationship.confidence.present?
                reasons << "Confidence: #{relationship.confidence}"
              end

              if relationship.respond_to?(:state) &&
                relationship.state.present?
                reasons << "State: #{relationship.state}"
              end

              reasons << "Connected through the ecosystem" if reasons.empty?

              reasons
            end

            def recommendation_payload(candidate)
              related = candidate[:entity]

              {
                id: related.id,
                title: entity_title(related),
                type: entity_type(related),
                score: candidate[:score],
                reasons: candidate[:reasons],
                relationship: relationship_type(candidate[:relationship]),
                action: recommended_action(related)
              }
            end

            def build_missions(candidates)
              candidates.first(3).map.with_index do |candidate, index|
                related = candidate[:entity]

                {
                  id: "explore-#{related.id}",
                  type: "explore_connection",
                  title: mission_title(index),
                  description:
                    "Explore how #{entity_title(related)} connects to this investigation.",
                  xp_reward: 20 + (index * 10),
                  target_id: related.id
                }
              end
            end

            def mission_title(index)
              case index
              when 0
                "Explore a strong connection"
              when 1
                "Discover a related entity"
              else
                "Expand your ecosystem"
              end
            end

            def stats(candidates)
              {
                candidates: candidates.length,
                strong_connections: candidates.count do |candidate|
                  candidate[:score] >= 70
                end,
                medium_connections: candidates.count do |candidate|
                  candidate[:score].between?(40, 69)
                end,
                weak_connections: candidates.count do |candidate|
                  candidate[:score] < 40
                end
              }
            end

            def relationship_type(relationship)
              return "connected" unless relationship.respond_to?(:relationship_kind)

              relationship.relationship_kind.presence || "connected"
            end

            def recommended_action(related)
              if related.respond_to?(:versions) && related.versions.exists?
                "follow_evolution"
              else
                "investigate"
              end
            rescue StandardError
              "investigate"
            end

            def entity_title(record)
              return record.name if record.respond_to?(:name) && record.name.present?
              return record.title if record.respond_to?(:title) && record.title.present?

              "Entity ##{record.id}"
            end


            def entity_type(record)
              if record.respond_to?(:entity_type)
                association = record.entity_type

                if association.present?
                  return association.name.to_s if
                    association.respond_to?(:name) && association.name.present?

                  return association.key.to_s if
                    association.respond_to?(:key) && association.key.present?

                  return association.slug.to_s if
                    association.respond_to?(:slug) && association.slug.present?
                end
              end

              record.class.name.demodulize.underscore
            rescue StandardError
              record.class.name.demodulize.underscore
            end


            def entity_payload(record)
              {
                id: record.id,
                title: entity_title(record),
                type: entity_type(record)
              }
            end
          end
        end
      end
    end
  end
end