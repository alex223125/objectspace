# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_metrics_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphMetricsService
            DEFAULT_SOURCE_KEY = :source_entity_id
            DEFAULT_TARGET_KEY = :target_entity_id

            def initialize(nodes:, edges:,
                           source_key: DEFAULT_SOURCE_KEY,
                           target_key: DEFAULT_TARGET_KEY)
              @nodes = normalize_records(nodes)
              @edges = normalize_records(edges)
              @source_key = source_key.to_s
              @target_key = target_key.to_s
            end

            def call
              node_ids = @nodes.filter_map { |node| value(node, "id") }.map(&:to_s).to_set
              connected_ids = Set.new
              degrees = Hash.new(0)

              @edges.each do |edge|
                source = value(edge, @source_key)&.to_s
                target = value(edge, @target_key)&.to_s

                next unless source && target
                next unless node_ids.include?(source) && node_ids.include?(target)

                connected_ids << source
                connected_ids << target
                degrees[source] += 1
                degrees[target] += 1
              end

              {
                node_count: @nodes.size,
                edge_count: @edges.size,
                connected_node_count: connected_ids.size,
                isolated_node_count: node_ids.size - connected_ids.size,
                average_degree: average_degree(node_ids.size, degrees),
                max_degree: degrees.values.max || 0,
                self_loop_count: self_loop_count(node_ids),
                density: density(node_ids.size, @edges.size),
                generated_at: Time.current.iso8601
              }
            end

            private

            def normalize_records(records)
              Array(records).map do |record|
                record.respond_to?(:attributes) ? record.attributes : record.to_h.stringify_keys
              end
            end

            def value(record, key)
              record[key] || record[key.to_sym]
            end

            def average_degree(node_count, degrees)
              return 0.0 if node_count.zero?

              (degrees.values.sum.to_f / node_count).round(3)
            end

            def self_loop_count(node_ids)
              @edges.count do |edge|
                source = value(edge, @source_key)&.to_s
                target = value(edge, @target_key)&.to_s

                source.present? &&
                  source == target &&
                  node_ids.include?(source)
              end
            end

            def density(node_count, edge_count)
              return 0.0 if node_count < 2

              possible_edges = node_count * (node_count - 1)
              (edge_count.to_f / possible_edges).clamp(0.0, 1.0).round(4)
            end
          end
        end
      end
    end
  end
end