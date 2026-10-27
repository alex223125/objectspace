
# frozen_string_literal: true

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class GraphPayloadPresenter
            NODE_FIELDS = %i[
              id name slug summary status workflow_state
              entity_type_id updated_at
            ].freeze

            EDGE_FIELDS = %i[
              id source target label relationship_kind state confidence
              source_name target_name
            ].freeze

            def initialize(payload)
              @payload = payload.deep_symbolize_keys
            end

            def call
              nodes = Array(@payload[:nodes]).map do |node|
                node = node.to_h.symbolize_keys
                NODE_FIELDS.to_h do |field|
                  [field, node[field]]
                end
              end

              ids = nodes.map { |node| node[:id].to_s }.to_set

              edges = Array(@payload[:edges]).filter_map do |edge|
                edge = edge.to_h.symbolize_keys

                source = edge[:source] || edge[:source_id]
                target = edge[:target] || edge[:target_id]

                next unless ids.include?(source.to_s)
                next unless ids.include?(target.to_s)

                EDGE_FIELDS.to_h do |field|
                  value =
                    case field
                    when :source then source
                    when :target then target
                    else edge[field]
                    end

                  [field, value]
                end
              end

              degrees = Hash.new(0)
              edges.each do |edge|
                degrees[edge[:source].to_s] += 1
                degrees[edge[:target].to_s] += 1
              end

              meta = @payload[:meta].to_h.symbolize_keys

              {
                nodes: nodes,
                edges: edges,
                meta: meta.merge(
                  node_count: nodes.size,
                  edge_count: edges.size,
                  connected_node_count: nodes.count do |node|
                    degrees[node[:id].to_s].positive?
                  end,
                  isolated_node_count: nodes.count do |node|
                    degrees[node[:id].to_s].zero?
                  end,
                  removed_dangling_edges:
                    Array(@payload[:edges]).size - edges.size
                )
              }
            end
          end
        end
      end
    end
  end
end