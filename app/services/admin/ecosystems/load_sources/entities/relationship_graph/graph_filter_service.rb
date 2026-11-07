
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphFilterService
            VALID_CONNECTION_STATES = %w[all connected isolated].freeze
            MAX_FILTER_VALUES = 100

            def initialize(
              nodes:,
              edges: [],
              states: nil,
              entity_type_ids: nil,
              connection: "all",
              relationship_types: nil
            )
              @nodes = Array(nodes)
              @edges = Array(edges)
              @states = normalize_values(states)
              @entity_type_ids = normalize_values(entity_type_ids)
              @connection = connection.to_s
              @relationship_types = normalize_values(relationship_types)
            end

            def call
              validate_connection!

              filtered_nodes = @nodes.select do |node|
                state_matches?(node) &&
                  entity_type_matches?(node)
              end

              filtered_edges = @edges.select do |edge|
                relationship_type_matches?(edge)
              end

              connected_ids = connected_node_ids(filtered_edges)

              filtered_nodes = filtered_nodes.select do |node|
                connection_matches?(node, connected_ids)
              end

              visible_ids = filtered_nodes.map { |node| read(node, :id).to_s }.to_set

              filtered_edges.select! do |edge|
                source = source_id(edge)
                target = target_id(edge)

                source && target &&
                  visible_ids.include?(source) &&
                  visible_ids.include?(target)
              end

              {
                nodes: filtered_nodes,
                edges: filtered_edges,
                meta: {
                  node_count: filtered_nodes.size,
                  edge_count: filtered_edges.size,
                  connected_node_count: connected_node_ids(filtered_edges).size,
                  isolated_node_count:
                    filtered_nodes.size - connected_node_ids(filtered_edges).size
                }
              }
            end

            private

            def normalize_values(values)
              normalized = Array(values).filter_map do |value|
                next if value.nil?

                string = value.to_s.strip
                string if string.present?
              end.uniq

              if normalized.size > MAX_FILTER_VALUES
                raise ArgumentError,
                      "too many filter values; maximum is #{MAX_FILTER_VALUES}"
              end

              normalized
            end

            def validate_connection!
              return if VALID_CONNECTION_STATES.include?(@connection)

              raise ArgumentError,
                    "connection must be all, connected, or isolated"
            end

            def state_matches?(node)
              return true if @states.empty?

              state = read(node, :workflow_state).presence ||
                read(node, :status)

              @states.include?(state.to_s)
            end

            def entity_type_matches?(node)
              return true if @entity_type_ids.empty?

              @entity_type_ids.include?(read(node, :entity_type_id).to_s)
            end

            def relationship_type_matches?(edge)
              return true if @relationship_types.empty?

              value = read(edge, :relationship_type).presence ||
                read(edge, :relationship_type_id)

              @relationship_types.include?(value.to_s)
            end

            def connection_matches?(node, connected_ids)
              id = read(node, :id).to_s

              case @connection
              when "connected"
                connected_ids.include?(id)
              when "isolated"
                !connected_ids.include?(id)
              else
                true
              end
            end

            def connected_node_ids(edges)
              edges.each_with_object(Set.new) do |edge, ids|
                source = source_id(edge)
                target = target_id(edge)

                ids << source if source
                ids << target if target
              end
            end

            def source_id(edge)
              value = read(edge, :source_entity_id) ||
                read(edge, :source_id) ||
                read(edge, :from_id)

              value.to_s if value
            end

            def target_id(edge)
              value = read(edge, :target_entity_id) ||
                read(edge, :target_id) ||
                read(edge, :to_id)

              value.to_s if value
            end

            def read(record, field)
              if record.respond_to?(:key?)
                return record[field] if record.key?(field)
                return record[field.to_s] if record.key?(field.to_s)
              end

              record.public_send(field) if record.respond_to?(field)
            end
          end
        end
      end
    end
  end
end