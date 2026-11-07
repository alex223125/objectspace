
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class GraphNeighborhoodService
            def call(graph:, node_id:, depth: 1)
              nodes = Array(graph[:nodes] || graph["nodes"])
              edges = Array(graph[:edges] || graph["edges"])
              max_depth = [[depth.to_i, 1].max, 5].min

              node_map = nodes.index_by do |node|
                read(node, :id).to_s
              end

              selected_id = node_id.to_s
              return empty_result unless node_map.key?(selected_id)

              visited = Set.new([selected_id])
              frontier = [selected_id]
              selected_edges = []

              max_depth.times do
                next_frontier = []

                edges.each do |edge|
                  source = read(edge, :source).to_s
                  target = read(edge, :target).to_s

                  next unless frontier.include?(source) ||
                    frontier.include?(target)

                  selected_edges << edge

                  neighbor = frontier.include?(source) ? target : source

                  next unless node_map.key?(neighbor)
                  next if visited.include?(neighbor)

                  visited << neighbor
                  next_frontier << neighbor
                end

                frontier = next_frontier.uniq
                break if frontier.empty?
              end

              {
                root_id: selected_id,
                nodes: visited.filter_map { |id| node_map[id] },
                edges: selected_edges.uniq,
                depth: max_depth
              }
            end

            private

            def read(record, key)
              record.respond_to?(:[]) ? (record[key] || record[key.to_s]) : nil
            end

            def empty_result
              { root_id: nil, nodes: [], edges: [], depth: 0 }
            end
          end
        end
      end
    end
  end
end