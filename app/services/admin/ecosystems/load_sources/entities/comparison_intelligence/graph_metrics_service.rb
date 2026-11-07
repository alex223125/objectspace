
# frozen_string_literal: true

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class GraphMetricsService
            def call(graph:)
              nodes = Array(graph[:nodes] || graph["nodes"])
              edges = Array(graph[:edges] || graph["edges"])

              ids = nodes.filter_map do |node|
                read(node, :id)&.to_s
              end.to_set

              valid_edges = edges.select do |edge|
                ids.include?(read(edge, :source).to_s) &&
                  ids.include?(read(edge, :target).to_s)
              end

              degrees = Hash.new(0)

              valid_edges.each do |edge|
                degrees[read(edge, :source).to_s] += 1
                degrees[read(edge, :target).to_s] += 1
              end

              {
                node_count: ids.length,
                edge_count: valid_edges.length,
                isolated_nodes: ids.count { |id| degrees[id].zero? },
                maximum_degree: degrees.values.max || 0,
                average_degree: ids.empty? ? 0 :
                                  (degrees.values.sum.to_f / ids.length).round(2),
                density: ids.length < 2 ? 0 :
                           (valid_edges.length.to_f / (ids.length * (ids.length - 1))).round(4)
              }
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