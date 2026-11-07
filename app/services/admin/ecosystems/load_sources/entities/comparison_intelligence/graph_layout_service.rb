
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class GraphLayoutService
            def call(graph:, width: 1000, height: 700)
              nodes = Array(graph[:nodes] || graph["nodes"])
              edges = Array(graph[:edges] || graph["edges"])

              return { nodes: [], edges: edges } if nodes.empty?

              ids = nodes.map { |node| read(node, :id).to_s }
              adjacency = Hash.new { |hash, key| hash[key] = [] }

              edges.each do |edge|
                source = read(edge, :source).to_s
                target = read(edge, :target).to_s
                adjacency[source] << target if ids.include?(target)
              end

              levels = {}
              roots = ids.reject do |id|
                edges.any? { |edge| read(edge, :target).to_s == id }
              end

              queue = roots.presence || [ids.first]
              queue.each { |id| levels[id] = 0 }

              until queue.empty?
                current = queue.shift

                adjacency[current].each do |neighbor|
                  next if levels.key?(neighbor)

                  levels[neighbor] = levels[current] + 1
                  queue << neighbor
                end
              end

              ids.each { |id| levels[id] ||= 0 }
              grouped = ids.group_by { |id| levels[id] }
              max_level = [grouped.keys.max.to_i, 1].max

              positioned = nodes.map do |node|
                id = read(node, :id).to_s
                level = levels[id]
                peers = grouped[level]
                index = peers.index(id)

                node.to_h.merge(
                  x: ((level + 1).to_f / (max_level + 1) * width).round,
                  y: ((index + 1).to_f / (peers.length + 1) * height).round
                )
              end

              { nodes: positioned, edges: edges }
            end

            private

            def read(record, key)
              record.respond_to?(:[]) ? (record[key] || record[key.to_s]) : nil
            end
          end
        end
      end
    end
  end
end