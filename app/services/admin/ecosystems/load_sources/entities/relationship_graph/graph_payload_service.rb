
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphPayloadService
            NODE_FIELDS = %i[
              id name slug summary description status workflow_state
              entity_type_id entity_type updated_at created_at
            ].freeze

            EDGE_FIELDS = %i[
              id source_entity_id target_entity_id source_id target_id
              source_id target_id relationship_type relationship_type_id
              name label status confidence evidence_count created_at updated_at
            ].uniq.freeze

            def initialize(nodes:, edges: [], meta: {})
              @nodes = Array(nodes)
              @edges = Array(edges)
              @meta = meta || {}
            end

            def call
              serialized_nodes = @nodes.map { |node| serialize_node(node) }
              serialized_edges = @edges.map { |edge| serialize_edge(edge) }

              {
                nodes: serialized_nodes,
                edges: serialized_edges,
                meta: build_meta(serialized_nodes, serialized_edges)
              }
            end

            private

            def serialize_node(record)
              attributes = extract_fields(record, NODE_FIELDS)

              attributes[:id] = read(record, :id).to_s
              attributes[:name] = read(record, :name).presence || "Unnamed entity"
              attributes[:status] ||= "unknown"

              attributes.compact
            end

            def serialize_edge(record)
              attributes = extract_fields(record, EDGE_FIELDS)

              source = first_value(
                record, :source_entity_id, :source_id, :from_id
              )

              target = first_value(
                record, :target_entity_id, :target_id, :to_id
              )

              attributes[:id] = read(record, :id).to_s if read(record, :id)
              attributes[:source_entity_id] = source.to_s if source
              attributes[:target_entity_id] = target.to_s if target
              attributes[:relationship_type] ||= "related"

              attributes.compact
            end

            def build_meta(nodes, edges)
              node_ids = nodes.map { |node| node[:id] }.to_set

              connected_ids = edges.each_with_object(Set.new) do |edge, ids|
                source = edge[:source_entity_id]
                target = edge[:target_entity_id]

                ids << source if source && node_ids.include?(source)
                ids << target if target && node_ids.include?(target)
              end

              supplied = @meta.to_h.symbolize_keys

              {
                node_count: nodes.length,
                edge_count: edges.length,
                connected_node_count: connected_ids.length,
                isolated_node_count: nodes.length - connected_ids.length,
                truncated: supplied.fetch(:truncated, false),
                generated_at: Time.current.iso8601
              }.merge(
                supplied.slice(:root_entity_id, :depth, :limit, :states)
              )
            end

            def extract_fields(record, fields)
              fields.each_with_object({}) do |field, result|
                value = read(record, field)
                result[field] = normalize_value(value) unless value.nil?
              end
            end

            def first_value(record, *fields)
              fields.each do |field|
                value = read(record, field)
                return value unless value.nil?
              end

              nil
            end

            def read(record, field)
              if record.respond_to?(:key?)
                return record[field] if record.key?(field)
                return record[field.to_s] if record.key?(field.to_s)
              end

              record.public_send(field) if record.respond_to?(field)
            end

            def normalize_value(value)
              case value
              when Time, DateTime, ActiveSupport::TimeWithZone
                value.iso8601
              when Symbol
                value.to_s
              else
                value
              end
            end
          end
        end
      end
    end
  end
end