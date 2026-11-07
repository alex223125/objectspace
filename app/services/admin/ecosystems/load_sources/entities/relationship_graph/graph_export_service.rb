
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_export_service.rb

require "csv"
require "json"
require "cgi"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphExportService
            FORMATS = %w[json csv graphml].freeze
            DEFAULT_FIELDS = %w[
              id name slug summary status entity_type_id
              source_entity_id target_entity_id
            ].freeze

            def initialize(nodes:, edges:, format: :json, fields: DEFAULT_FIELDS)
              @nodes = Array(nodes)
              @edges = Array(edges)
              @format = format.to_s.downcase
              @fields = Array(fields).map(&:to_s)
            end

            def call
              raise ArgumentError, "Unsupported export format" unless FORMATS.include?(@format)

              {
                filename: "relationship-graph-#{Time.current.strftime('%Y%m%d-%H%M%S')}.#{extension}",
                content_type: content_type,
                content: export_content,
                node_count: @nodes.size,
                edge_count: @edges.size
              }
            end

            private

            def export_content
              case @format
              when "json"
                JSON.pretty_generate(
                  nodes: @nodes.map { |record| selected_attributes(record) },
                  edges: @edges.map { |record| selected_attributes(record) },
                  meta: {
                    node_count: @nodes.size,
                    edge_count: @edges.size,
                    exported_at: Time.current.iso8601
                  }
                )
              when "csv"
                export_csv
              when "graphml"
                export_graphml
              end
            end

            def export_csv
              CSV.generate(headers: true) do |csv|
                csv << %w[record_type id name source_entity_id target_entity_id status]

                @nodes.each do |record|
                  data = attributes_for(record)
                  csv << [
                    "entity",
                    data["id"],
                    data["name"],
                    nil,
                    nil,
                    data["status"]
                  ]
                end

                @edges.each do |record|
                  data = attributes_for(record)
                  csv << [
                    "relationship",
                    data["id"],
                    data["name"],
                    data["source_entity_id"],
                    data["target_entity_id"],
                    data["status"]
                  ]
                end
              end
            end

            def export_graphml
              nodes_xml = @nodes.map do |record|
                data = attributes_for(record)
                next if data["id"].blank?

                %(<node id="#{xml(data['id'])}"><data key="label">#{xml(data['name'])}</data></node>)
              end.compact.join("\n")

              edges_xml = @edges.filter_map do |record|
                data = attributes_for(record)
                source = data["source_entity_id"]
                target = data["target_entity_id"]

                next if source.blank? || target.blank?

                %(<edge source="#{xml(source)}" target="#{xml(target)}"/>)
              end.join("\n")

              <<~XML
                <?xml version="1.0" encoding="UTF-8"?>
                <graphml xmlns="http://graphml.graphdrawing.org/xmlns">
                  <key id="label" for="node" attr.name="label" attr.type="string"/>
                  <graph id="ObjectSpaceRelationshipGraph" edgedefault="directed">
                    #{nodes_xml}
                    #{edges_xml}
                  </graph>
                </graphml>
              XML
            end

            def selected_attributes(record)
              data = attributes_for(record)
              data.slice(*@fields)
            end

            def attributes_for(record)
              if record.respond_to?(:attributes)
                record.attributes.stringify_keys
              elsif record.respond_to?(:to_h)
                record.to_h.stringify_keys
              else
                {}
              end
            end

            def xml(value)
              CGI.escapeHTML(value.to_s)
            end

            def extension
              @format
            end

            def content_type
              {
                "json" => "application/json",
                "csv" => "text/csv; charset=utf-8",
                "graphml" => "application/graphml+xml"
              }.fetch(@format)
            end
          end
        end
      end
    end
  end
end