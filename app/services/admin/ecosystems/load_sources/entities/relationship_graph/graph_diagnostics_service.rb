# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_diagnostics_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphDiagnosticsService
            def initialize(nodes:, edges:,
                           source_key: :source_entity_id,
                           target_key: :target_entity_id)
              @nodes = normalize_records(nodes)
              @edges = normalize_records(edges)
              @source_key = source_key.to_s
              @target_key = target_key.to_s
            end

            def call
              node_ids = @nodes.filter_map { |node| read(node, "id") }.map(&:to_s).to_set
              issues = []

              duplicate_ids(@nodes).each do |id|
                issues << issue(
                  :error, :duplicate_node_id,
                  "Multiple nodes have the same ID.",
                  entity_id: id
                )
              end

              @edges.each_with_index do |edge, index|
                source = read(edge, @source_key)&.to_s
                target = read(edge, @target_key)&.to_s

                if source.blank? || target.blank?
                  issues << issue(
                    :error, :missing_endpoint,
                    "Relationship is missing a source or target.",
                    edge_index: index
                  )
                  next
                end

                unless node_ids.include?(source)
                  issues << issue(
                    :warning, :orphan_source,
                    "Relationship source is not present in the graph payload.",
                    edge_index: index, entity_id: source
                  )
                end

                unless node_ids.include?(target)
                  issues << issue(
                    :warning, :orphan_target,
                    "Relationship target is not present in the graph payload.",
                    edge_index: index, entity_id: target
                  )
                end

                if source == target
                  issues << issue(
                    :warning, :self_relationship,
                    "Relationship points to the same entity.",
                    edge_index: index, entity_id: source
                  )
                end
              end

              {
                issue_count: issues.size,
                error_count: issues.count { |item| item[:severity] == "error" },
                warning_count: issues.count { |item| item[:severity] == "warning" },
                healthy: issues.none? { |item| item[:severity] == "error" },
                issues: issues
              }
            end

            private

            def normalize_records(records)
              Array(records).map do |record|
                record.respond_to?(:attributes) ? record.attributes : record.to_h.stringify_keys
              end
            end

            def read(record, key)
              record[key] || record[key.to_sym]
            end

            def duplicate_ids(records)
              records.filter_map { |record| read(record, "id") }
                     .map(&:to_s)
                     .tally
                     .select { |_id, count| count > 1 }
                     .keys
            end

            def issue(severity, code, message, **details)
              {
                severity: severity.to_s,
                code: code.to_s,
                message: message,
                details: details
              }
            end
          end
        end
      end
    end
  end
end