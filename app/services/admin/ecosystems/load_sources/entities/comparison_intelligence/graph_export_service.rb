
# frozen_string_literal: true

require "csv"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class GraphExportService
            FORMATS = %w[json csv].freeze

            def call(graph:, format:)
              format = format.to_s.downcase
              raise ArgumentError, "Unsupported graph format" unless FORMATS.include?(format)

              case format
              when "json"
                JSON.pretty_generate(
                  nodes: Array(graph[:nodes] || graph["nodes"]),
                  edges: Array(graph[:edges] || graph["edges"])
                )
              when "csv"
                export_csv(graph)
              end
            end

            private

            def export_csv(graph)
              CSV.generate do |csv|
                csv << %w[record_type id source target label type]

                Array(graph[:nodes] || graph["nodes"]).each do |node|
                  csv << [
                    "node",
                    read(node, :id),
                    nil,
                    nil,
                    read(node, :label),
                    read(node, :type)
                  ]
                end

                Array(graph[:edges] || graph["edges"]).each do |edge|
                  csv << [
                    "edge",
                    read(edge, :id),
                    read(edge, :source),
                    read(edge, :target),
                    read(edge, :label),
                    read(edge, :type)
                  ]
                end
              end
            end

            def read(record, key)
              record.respond_to?(:[]) ? (record[key] || record[key.to_s]) : nil
            end
          end
        end
      end
    end
  end
end