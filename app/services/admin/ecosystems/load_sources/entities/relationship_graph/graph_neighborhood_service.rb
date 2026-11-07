
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphNeighborhoodService
            DEFAULT_DEPTH = 1
            MAX_DEPTH = 4
            DEFAULT_LIMIT = 100
            MAX_LIMIT = 500

            Result = Struct.new(:node_ids, :edges, :depth, :truncated,
                                keyword_init: true)

            def initialize(
              entity_id:,
              relationship_scope:,
              source_column: :source_entity_id,
              target_column: :target_entity_id,
              depth: DEFAULT_DEPTH,
              limit: DEFAULT_LIMIT
            )
              @entity_id = entity_id.to_s
              @relationship_scope = relationship_scope
              @source_column = source_column.to_sym
              @target_column = target_column.to_sym
              @depth = bounded_integer(depth, 0, MAX_DEPTH, "depth")
              @limit = bounded_integer(limit, 1, MAX_LIMIT, "limit")
            end

            def call
              validate_scope!

              visited = Set.new([@entity_id])
              frontier = [@entity_id]
              collected_edges = {}
              truncated = false

              @depth.times do
                break if frontier.empty?

                relationships = fetch_edges(frontier)

                next_frontier = []

                relationships.each do |edge|
                  collected_edges[edge.id.to_s] = edge

                  source = endpoint(edge, @source_column)
                  target = endpoint(edge, @target_column)

                  [source, target].compact.each do |neighbor_id|
                    neighbor_id = neighbor_id.to_s
                    next if visited.include?(neighbor_id)

                    if visited.size >= @limit
                      truncated = true
                      next
                    end

                    visited << neighbor_id
                    next_frontier << neighbor_id
                  end
                end

                frontier = next_frontier.uniq
              end

              Result.new(
                node_ids: visited.to_a,
                edges: collected_edges.values,
                depth: @depth,
                truncated: truncated
              )
            end

            private

            def validate_scope!
              unless @relationship_scope.respond_to?(:where) &&
                @relationship_scope.respond_to?(:klass)
                raise ArgumentError,
                      "relationship_scope must be an ActiveRecord relation"
              end

              columns = @relationship_scope.klass.column_names

              unless columns.include?(@source_column.to_s) &&
                columns.include?(@target_column.to_s)
                raise ArgumentError,
                      "relationship endpoint columns are not configured correctly"
              end
            end

            def fetch_edges(frontier)
              @relationship_scope
                .where(@source_column => frontier)
                .or(@relationship_scope.where(@target_column => frontier))
                .limit(MAX_LIMIT * 4)
                .to_a
            end

            def endpoint(record, column)
              record.public_send(column)
            end

            def bounded_integer(value, minimum, maximum, name)
              integer = Integer(value.to_s, 10)

              unless integer.between?(minimum, maximum)
                raise ArgumentError,
                      "#{name} must be between #{minimum} and #{maximum}"
              end

              integer
            rescue ArgumentError, TypeError
              raise ArgumentError, "invalid #{name}"
            end
          end
        end
      end
    end
  end
end