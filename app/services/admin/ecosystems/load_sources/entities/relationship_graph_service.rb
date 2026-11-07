
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph_service.rb
#
# Main orchestration service for the entity relationship graph.
#
# Responsibilities:
# - Load the graph through the existing application service when available.
# - Normalize node and edge collections.
# - Provide search, filtering, neighborhood, metrics, and diagnostics.
# - Return a stable, JSON-friendly payload for Rails views and API endpoints.
# - Avoid modifying relationship records during graph exploration.
#
# Compatible with the modular services under:
#   entities/relationship_graph/

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class RelationshipGraphService
          DEFAULT_LIMIT = 100
          MAX_LIMIT = 500
          DEFAULT_DEPTH = 1
          MAX_DEPTH = 5

          class Error < StandardError; end
          class InvalidQuery < Error; end

          attr_reader :options

          def initialize(options = {})
            @options = options.to_h.symbolize_keys
          end

          # Main public entry point.
          #
          # Example:
          #   result = RelationshipGraphService.new(
          #     ecosystem: ecosystem,
          #     root_entity_id: params[:entity_id],
          #     limit: params[:limit]
          #   ).call
          #
          # Returns:
          #   {
          #     nodes: [],
          #     edges: [],
          #     meta: {}
          #   }
          def call
            payload = load_payload
            nodes = normalize_nodes(payload[:nodes])
            edges = normalize_edges(payload[:edges], nodes)

            nodes = apply_search(nodes)
            nodes = apply_node_filters(nodes)
            edges = filter_edges(edges, nodes)

            {
              nodes: nodes,
              edges: edges,
              meta: build_metadata(nodes, edges, payload[:meta])
            }
          end

          # A compact summary suitable for dashboard cards.
          def metrics
            payload = call
            nodes = payload[:nodes]
            edges = payload[:edges]

            {
              node_count: nodes.size,
              edge_count: edges.size,
              connected_node_count: connected_node_count(nodes, edges),
              isolated_node_count: isolated_node_count(nodes, edges),
              relationship_density: relationship_density(nodes.size, edges.size),
              generated_at: Time.current.iso8601
            }
          end

          # Search nodes by name, ID, slug, summary, or workflow state.
          def search(query = nil)
            query = query.nil? ? options[:query] : query
            payload = call

            return payload if query.blank?

            term = query.to_s.strip.downcase

            payload.merge(
              nodes: payload[:nodes].select do |node|
                searchable_values(node).any? do |value|
                  value.to_s.downcase.include?(term)
                end
              end
            )
          end

          # Return a node and its immediate neighbors.
          def neighborhood(entity_id, depth: nil)
            payload = call
            depth = normalize_depth(depth || options[:depth])

            nodes_by_id = payload[:nodes].index_by { |node| node[:id].to_s }
            root_id = entity_id.to_s

            raise Error, "Entity not found in graph" unless nodes_by_id.key?(root_id)

            selected_ids = [root_id]
            frontier = [root_id]

            depth.times do
              neighbors = payload[:edges].filter_map do |edge|
                source = edge[:source].to_s
                target = edge[:target].to_s

                if frontier.include?(source)
                  target
                elsif frontier.include?(target)
                  source
                end
              end

              frontier = neighbors.uniq - selected_ids
              selected_ids.concat(frontier)
              break if frontier.empty?
            end

            selected_nodes = payload[:nodes].select do |node|
              selected_ids.include?(node[:id].to_s)
            end

            selected_edges = payload[:edges].select do |edge|
              selected_ids.include?(edge[:source].to_s) &&
                selected_ids.include?(edge[:target].to_s)
            end

            payload.merge(
              nodes: selected_nodes,
              edges: selected_edges,
              meta: payload[:meta].merge(
                root_entity_id: root_id,
                depth: depth
              )
            )
          end

          # Diagnostics describe graph structure, not the validity of
          # domain-specific relationships.
          def diagnostics
            payload = call
            nodes = payload[:nodes]
            edges = payload[:edges]

            {
              node_count: nodes.size,
              edge_count: edges.size,
              isolated_node_ids: isolated_node_ids(nodes, edges),
              dangling_edge_count: dangling_edge_count(edges, nodes),
              duplicate_node_ids: duplicate_node_ids(nodes),
              duplicate_edge_count: duplicate_edge_count(edges),
              warnings: diagnostic_warnings(nodes, edges)
            }
          end

          private

          def load_payload
            service = options[:payload_service]

            if service
              result = service.respond_to?(:call) ? service.call : service
              return symbolize_payload(result)
            end

            existing_service_payload
          end

          # Adapter for an existing application-specific graph service.
          #
          # Pass an existing service instance as :payload_service if its
          # constructor or method signature differs from this adapter.
          def existing_service_payload
            service_class =
              "::Admin::Ecosystems::LoadSources::Entities::RelationshipGraphPayloadService"

            if service_class.safe_constantize
              service = service_class.constantize.new(options)
              result = service.respond_to?(:call) ? service.call : {}
              return symbolize_payload(result)
            end

            # An empty payload is safer than guessing your application's
            # entity model, relationship schema, or authorization rules.
            {
              nodes: [],
              edges: [],
              meta: {
                warning: "No graph payload service has been configured."
              }
            }
          end

          def symbolize_payload(payload)
            payload = payload.to_h if payload.respond_to?(:to_h)
            payload = {} unless payload.is_a?(Hash)

            normalized = payload.deep_symbolize_keys

            {
              nodes: Array(normalized[:nodes]),
              edges: Array(normalized[:edges]),
              meta: normalized[:meta].is_a?(Hash) ? normalized[:meta] : {}
            }
          end

          def normalize_nodes(nodes)
            Array(nodes).filter_map do |node|
              node = node.to_h.deep_symbolize_keys if node.respond_to?(:to_h)
              next unless node.is_a?(Hash)
              next if node[:id].blank?

              node.merge(
                id: node[:id].to_s,
                name: node[:name].presence || "Unnamed entity"
              )
            end
          end

          def normalize_edges(edges, nodes)
            known_ids = nodes.map { |node| node[:id].to_s }.to_set

            Array(edges).filter_map do |edge|
              edge = edge.to_h.deep_symbolize_keys if edge.respond_to?(:to_h)
              next unless edge.is_a?(Hash)

              source = edge[:source] || edge[:source_id] ||
                edge.dig(:from, :id)
              target = edge[:target] || edge[:target_id] ||
                edge.dig(:to, :id)

              next if source.blank? || target.blank?
              next unless known_ids.include?(source.to_s)
              next unless known_ids.include?(target.to_s)

              edge.merge(
                source: source.to_s,
                target: target.to_s
              )
            end
          end

          def apply_search(nodes)
            query = options[:query]
            return nodes if query.blank?

            term = query.to_s.strip.downcase

            nodes.select do |node|
              searchable_values(node).any? do |value|
                value.to_s.downcase.include?(term)
              end
            end
          end

          def apply_node_filters(nodes)
            result = nodes

            if options[:entity_type_id].present?
              expected = options[:entity_type_id].to_s

              result = result.select do |node|
                node[:entity_type_id].to_s == expected
              end
            end

            if options[:status].present?
              expected = Array(options[:status]).map(&:to_s)

              result = result.select do |node|
                expected.include?(
                  (node[:status] || node[:workflow_state]).to_s
                )
              end
            end

            result
          end

          def filter_edges(edges, nodes)
            visible_ids = nodes.map { |node| node[:id].to_s }.to_set

            edges.select do |edge|
              visible_ids.include?(edge[:source].to_s) &&
                visible_ids.include?(edge[:target].to_s)
            end
          end

          def searchable_values(node)
            %i[
              id name slug summary status workflow_state entity_type_id
            ].filter_map { |key| node[key] }
          end

          def build_metadata(nodes, edges, source_meta)
            source_meta = source_meta.to_h.deep_symbolize_keys

            source_meta.merge(
              node_count: nodes.size,
              edge_count: edges.size,
              connected_node_count: connected_node_count(nodes, edges),
              isolated_node_count: isolated_node_count(nodes, edges),
              root_entity_id: options[:root_entity_id],
              depth: normalize_depth(options[:depth]),
              limit: normalize_limit(options[:limit]),
              generated_at: Time.current.iso8601
            )
          end

          def connected_node_count(nodes, edges)
            connected_ids = edges.flat_map do |edge|
              [edge[:source].to_s, edge[:target].to_s]
            end.to_set

            nodes.count { |node| connected_ids.include?(node[:id].to_s) }
          end

          def isolated_node_count(nodes, edges)
            nodes.size - connected_node_count(nodes, edges)
          end

          def isolated_node_ids(nodes, edges)
            connected_ids = edges.flat_map do |edge|
              [edge[:source].to_s, edge[:target].to_s]
            end.to_set

            nodes.filter_map do |node|
              node[:id] unless connected_ids.include?(node[:id].to_s)
            end
          end

          def relationship_density(node_count, edge_count)
            return 0.0 if node_count < 2

            possible_edges = node_count * (node_count - 1)
            (edge_count.to_f / possible_edges).round(4)
          end

          def dangling_edge_count(edges, nodes)
            known_ids = nodes.map { |node| node[:id].to_s }.to_set

            edges.count do |edge|
              !known_ids.include?(edge[:source].to_s) ||
                !known_ids.include?(edge[:target].to_s)
            end
          end

          def duplicate_node_ids(nodes)
            ids = nodes.map { |node| node[:id].to_s }

            ids.tally.filter_map do |id, count|
              id if count > 1
            end
          end

          def duplicate_edge_count(edges)
            keys = edges.map do |edge|
              [edge[:source].to_s, edge[:target].to_s]
            end

            keys.size - keys.uniq.size
          end

          def diagnostic_warnings(nodes, edges)
            warnings = []

            warnings << "Graph contains no entities." if nodes.empty?

            if nodes.any? && edges.empty?
              warnings << "No relationships are present in this graph."
            end

            if isolated_node_count(nodes, edges).positive?
              warnings << "Some entities have no visible relationships."
            end

            warnings
          end

          def normalize_limit(value)
            number = Integer(value || DEFAULT_LIMIT)
            number.clamp(1, MAX_LIMIT)
          rescue ArgumentError, TypeError
            DEFAULT_LIMIT
          end

          def normalize_depth(value)
            number = Integer(value || DEFAULT_DEPTH)
            number.clamp(1, MAX_DEPTH)
          rescue ArgumentError, TypeError
            DEFAULT_DEPTH
          end
        end
      end
    end
  end
end