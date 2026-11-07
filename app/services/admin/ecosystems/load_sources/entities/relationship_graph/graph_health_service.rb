# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_health_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphHealthService
            def initialize(nodes:, edges:,
                           source_key: :source_entity_id,
                           target_key: :target_entity_id,
                           stale_after: 30.days)
              @nodes = Array(nodes)
              @edges = Array(edges)
              @source_key = source_key
              @target_key = target_key
              @stale_after = stale_after
            end

            def call
              diagnostics = GraphDiagnosticsService.new(
                nodes: @nodes,
                edges: @edges,
                source_key: @source_key,
                target_key: @target_key
              ).call

              node_records = normalize_records(@nodes)
              missing_names = node_records.count do |node|
                read(node, "name").blank?
              end

              stale_nodes = node_records.count do |node|
                timestamp = read(node, "updated_at")
                next false if timestamp.blank?

                parsed = timestamp.respond_to?(:to_time) ? timestamp.to_time : Time.zone.parse(timestamp.to_s)
                parsed < @stale_after.ago
              rescue ArgumentError, TypeError
                false
              end

              status =
                if diagnostics[:error_count].positive?
                  "critical"
                elsif diagnostics[:warning_count].positive? ||
                  missing_names.positive? ||
                  stale_nodes.positive?
                  "attention"
                else
                  "healthy"
                end

              {
                status: status,
                healthy: status == "healthy",
                entity_count: node_records.size,
                relationship_count: @edges.size,
                missing_name_count: missing_names,
                stale_entity_count: stale_nodes,
                diagnostic_issue_count: diagnostics[:issue_count],
                error_count: diagnostics[:error_count],
                warning_count: diagnostics[:warning_count],
                checked_at: Time.current.iso8601
              }
            end

            private

            def normalize_records(records)
              Array(records).map do |record|
                record.respond_to?(:attributes) ? record.attributes : record.to_h.stringify_keys
              end
            end

            def read(record, key)
              record[key.to_s] || record[key.to_sym]
            end
          end
        end
      end
    end
  end
end