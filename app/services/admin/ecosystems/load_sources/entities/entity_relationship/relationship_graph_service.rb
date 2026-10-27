
# frozen_string_literal: true

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class RelationshipGraphService
            DEFAULT_LIMIT = 100
            MAX_LIMIT = 500
            MAX_DEPTH = 3

            DEFAULT_STATES = %w[confirmed suggested].freeze
            ALLOWED_STATES = %w[
              confirmed suggested rejected archived
            ].freeze

            def initialize(
              entity_ids: nil,
              root_entity_id: nil,
              limit: DEFAULT_LIMIT,
              depth: 1,
              states: nil
            )
              @entity_ids = parse_ids(entity_ids)
              @root_entity_id = positive_integer(root_entity_id)
              @limit = bounded_integer(limit, DEFAULT_LIMIT, 1, MAX_LIMIT)
              @depth = bounded_integer(depth, 1, 1, MAX_DEPTH)
              @states = normalize_states(states)
            end

            def call
              entities = load_entities
              entity_ids = entities.map(&:id)
              entities_by_id = entities.index_by(&:id)

              relationships = load_relationships(entity_ids)

              nodes = entities.map do |entity|
                {
                  id: entity.id,
                  name: entity.name.presence || "Entity ##{entity.id}",
                  slug: optional_attribute(entity, :slug),
                  summary: optional_attribute(entity, :summary),
                  status: optional_attribute(entity, :status),
                  workflow_state: optional_attribute(entity, :workflow_state),
                  entity_type_id: optional_attribute(entity, :entity_type_id),
                  updated_at: entity.updated_at
                }
              end

              edges = relationships.map do |relationship|
                source = entities_by_id[relationship.source_entity_id]
                target = entities_by_id[relationship.target_entity_id]

                {
                  id: relationship.id,
                  source: relationship.source_entity_id,
                  target: relationship.target_entity_id,
                  source_id: relationship.source_entity_id,
                  target_id: relationship.target_entity_id,
                  source_entity_id: relationship.source_entity_id,
                  target_entity_id: relationship.target_entity_id,
                  source_name: entity_name(source, relationship.source_entity_id),
                  target_name: entity_name(target, relationship.target_entity_id),
                  label: relationship.relationship_kind.to_s.humanize,
                  relationship_kind: relationship.relationship_kind,
                  confidence: relationship.confidence,
                  state: relationship.state,
                  evidence: relationship.evidence,
                  last_discovered_at: relationship.last_discovered_at,
                  created_at: relationship.created_at,
                  updated_at: relationship.updated_at
                }
              end

              degrees = Hash.new(0)

              edges.each do |edge|
                degrees[edge[:source]] += 1
                degrees[edge[:target]] += 1
              end

              {
                nodes: nodes,
                edges: edges,
                meta: {
                  node_count: nodes.size,
                  edge_count: edges.size,
                  root_entity_id: @root_entity_id,
                  depth: @depth,
                  limit: @limit,
                  states: @states,
                  isolated_node_count: nodes.count do |node|
                    degrees[node[:id]].zero?
                  end,
                  connected_node_count: nodes.count do |node|
                    degrees[node[:id]].positive?
                  end,
                  truncated: nodes.size >= @limit,
                  generated_at: Time.now.utc.iso8601
                }
              }
            end

            private

            def entity_model
              ::Ecosystems::LoadSources::Entity::Entity
            end

            def relationship_model
              ::Ecosystems::LoadSources::Entity::EntityRelationship
            end

            def parse_ids(value)
              values = value.is_a?(Array) ? value : [value]

              values.compact
                    .flat_map { |item| item.to_s.split(",") }
                    .filter_map { |item| positive_integer(item) }
                    .uniq
            end

            def positive_integer(value)
              number = Integer(value.to_s, 10)
              number.positive? ? number : nil
            rescue ArgumentError, TypeError
              nil
            end

            def bounded_integer(value, default, minimum, maximum)
              number = Integer(value.to_s, 10)
              return default if number < minimum

              [number, maximum].min
            rescue ArgumentError, TypeError
              default
            end

            def normalize_states(value)
              requested = if value.nil?
                            DEFAULT_STATES
                          else
                            values = value.is_a?(Array) ? value : [value]

                            values.compact
                                  .flat_map { |item| item.to_s.split(",") }
                                  .map(&:strip)
                                  .reject(&:blank?)
                                  .uniq
                          end

              requested = DEFAULT_STATES if requested.empty?
              requested & ALLOWED_STATES
            end

            def relationship_scope
              scope = relationship_model.unscoped
              scope = scope.where(state: @states) if @states.any?
              scope
            end

            def load_entities
              scope = entity_model.unscoped

              if @root_entity_id
                return [] unless scope.exists?(id: @root_entity_id)

                ids = traversed_ids([@root_entity_id])
                return scope.where(id: ids).order(:id).to_a
              end

              if @entity_ids.any?
                existing_ids = scope.where(id: @entity_ids).pluck(:id)
                ids = traversed_ids(existing_ids)

                return scope.where(id: ids).order(:id).to_a
              end

              # Select entities participating in the requested relationship
              # states first. This avoids an arbitrary first page of isolated
              # entities hiding an otherwise connected graph.
              connected_ids = relationship_scope
                                .where.not(source_entity_id: nil)
                                .where.not(target_entity_id: nil)
                                .order(:id)
                                .limit(@limit)
                                .pluck(:source_entity_id, :target_entity_id)
                                .flatten
                                .compact
                                .uniq
                                .first(@limit)

              if connected_ids.any?
                scope.where(id: connected_ids).order(:id).to_a
              else
                # A genuinely disconnected dataset should still be inspectable.
                scope.order(:id).limit(@limit).to_a
              end
            end

            def traversed_ids(initial_ids)
              available = initial_ids.uniq.first(@limit)
              frontier = available.dup

              @depth.times do
                break if frontier.empty? || available.size >= @limit

                connected = relationship_scope
                              .where(
                                "source_entity_id IN (:ids) OR " \
                                  "target_entity_id IN (:ids)",
                                ids: frontier
                              )
                              .order(:id)
                              .pluck(:source_entity_id, :target_entity_id)
                              .flatten
                              .compact
                              .uniq

                frontier = connected - available
                frontier = frontier.first(@limit - available.size)

                available.concat(frontier)
              end

              available
            end

            def load_relationships(entity_ids)
              return [] if entity_ids.empty?

              relationship_scope
                .where(source_entity_id: entity_ids)
                .where(target_entity_id: entity_ids)
                .order(:id)
                .to_a
            end

            def entity_name(entity, fallback_id)
              entity&.name.presence || "Entity ##{fallback_id}"
            end

            def optional_attribute(record, attribute)
              record.public_send(attribute) if record.respond_to?(attribute)
            end
          end
        end
      end
    end
  end
end