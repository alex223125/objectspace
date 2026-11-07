
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class GraphPayloadService
            def call(nodes:, edges:)
              normalized_nodes = Array(nodes).filter_map do |node|
                attributes = node.to_h.stringify_keys
                id = attributes["id"].presence

                next unless id

                {
                  id: id.to_s,
                  label: attributes["label"].presence ||
                    attributes["name"].presence || id.to_s,
                  type: attributes["type"].presence || "entity",
                  risk: attributes["risk"].presence || "low",
                  metadata: attributes["metadata"].is_a?(Hash) ?
                              attributes["metadata"] : {}
                }
              end

              ids = normalized_nodes.map { |node| node[:id] }.to_set

              normalized_edges = Array(edges).filter_map do |edge|
                attributes = edge.to_h.stringify_keys
                source = attributes["source_id"].to_s
                target = attributes["target_id"].to_s

                next unless ids.include?(source) && ids.include?(target)

                {
                  id: attributes["id"].presence || "#{source}:#{target}",
                  source: source,
                  target: target,
                  label: attributes["label"].presence ||
                    attributes["type"].presence || "related",
                  type: attributes["type"].presence || "related"
                }
              end

              {
                nodes: normalized_nodes,
                edges: normalized_edges,
                node_count: normalized_nodes.length,
                edge_count: normalized_edges.length
              }
            end
          end
        end
      end
    end
  end
end