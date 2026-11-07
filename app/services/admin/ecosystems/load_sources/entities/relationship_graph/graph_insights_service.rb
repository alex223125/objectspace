
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_insights_service.rb

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphInsightsService
            DEFAULT_SOURCE_KEY = :source_entity_id
            DEFAULT_TARGET_KEY = :target_entity_id
            DEFAULT_LIMIT = 10
            MAX_LIMIT = 100

            def initialize(nodes:, edges:,
                           source_key: DEFAULT_SOURCE_KEY,
                           target_key: DEFAULT_TARGET_KEY,
                           limit: DEFAULT_LIMIT)
              @nodes = normalize_records(nodes)
              @edges = normalize_records(edges)
              @source_key = source_key.to_s
              @target_key = target_key.to_s
              @limit = [[limit.to_i, 1].max, MAX_LIMIT].min
            end

            def call
              node_by_id = @nodes.each_with_object({}) do |node, result|
                id = read(node, "id")
                result[id.to_s] = node if id.present?
              end

              degrees = Hash.new(0)
              valid_edges = 0

              @edges.each do |edge|
                source = read(edge, @source_key)&.to_s
                target = read(edge, @target_key)&.to_s

                next unless source && target
                next unless node_by_id.key?(source) && node_by_id.key?(target)

                degrees[source] += 1
                degrees[target] += 1
                valid_edges += 1
              end

              connected_count = degrees.count { |_id, degree| degree.positive? }
              isolated_ids = node_by_id.keys.reject { |id| degrees[id].positive? }

              {
                summary: {
                  entity_count: node_by_id.size,
                  relationship_count: @edges.size,
                  valid_relationship_count: valid_edges,
                  connected_entity_count: connected_count,
                  isolated_entity_count: isolated_ids.size,
                  average_degree: average_degree(node_by_id.size, degrees)
                },
                most_connected: degrees.sort_by { |id, degree| [-degree, id] }
                                       .first(@limit)
                                       .map { |id, degree| entity_insight(node_by_id[id], degree) },
                isolated_entities: isolated_ids.first(@limit).map do |id|
                  entity_insight(node_by_id[id], 0)
                end,
                observations: observations(
                  node_by_id.size,
                  @edges.size,
                  connected_count,
                  isolated_ids.size
                ),
                generated_at: Time.current.iso8601
              }
            end

            private

            def normalize_records(records)
              Array(records).map do |record|
                if record.respond_to?(:attributes)
                  record.attributes.stringify_keys
                elsif record.respond_to?(:to_h)
                  record.to_h.stringify_keys
                else
                  {}
                end
              end
            end

            def read(record, key)
              record[key.to_s] || record[key.to_sym]
            end

            def entity_insight(record, degree)
              {
                id: read(record, "id").to_s,
                name: read(record, "name").presence || "Unnamed entity",
                degree: degree
              }
            end

            def average_degree(node_count, degrees)
              return 0.0 if node_count.zero?

              (degrees.values.sum.to_f / node_count).round(2)
            end

            def observations(node_count, edge_count, connected_count, isolated_count)
              result = []

              if node_count.zero?
                result << {
                  type: "empty_graph",
                  severity: "info",
                  message: "No entities are available in this graph."
                }
              elsif edge_count.zero?
                result << {
                  type: "no_relationships",
                  severity: "warning",
                  message: "No relationships are present in the supplied graph."
                }
              end

              if isolated_count.positive?
                result << {
                  type: "isolated_entities",
                  severity: "warning",
                  count: isolated_count,
                  message: "#{isolated_count} entities have no visible relationships."
                }
              end

              if connected_count == node_count && node_count.positive?
                result << {
                  type: "all_entities_connected",
                  severity: "success",
                  message: "Every entity has at least one visible relationship."
                }
              end

              result
            end
          end
        end
      end
    end
  end
end