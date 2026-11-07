
# frozen_string_literal: true

# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_validation_service.rb

require "set"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphValidationService
            DEFAULT_MAX_NODES = 5_000
            DEFAULT_MAX_EDGES = 20_000

            def initialize(nodes:, edges:,
                           source_key: :source_entity_id,
                           target_key: :target_entity_id,
                           max_nodes: DEFAULT_MAX_NODES,
                           max_edges: DEFAULT_MAX_EDGES)
              @nodes = nodes
              @edges = edges
              @source_key = source_key.to_s
              @target_key = target_key.to_s
              @max_nodes = max_nodes.to_i
              @max_edges = max_edges.to_i
            end

            def call
              errors = []
              warnings = []

              unless @nodes.is_a?(Array)
                return invalid_result("Nodes must be an array")
              end

              unless @edges.is_a?(Array)
                return invalid_result("Edges must be an array")
              end

              if @nodes.size > @max_nodes
                errors << "Node count exceeds the configured limit"
              end

              if @edges.size > @max_edges
                errors << "Relationship count exceeds the configured limit"
              end

              node_ids = []
              @nodes.each_with_index do |node, index|
                unless record_like?(node)
                  errors << "Node at index #{index} must be a hash or model record"
                  next
                end

                id = read(node, "id")
                if id.blank?
                  errors << "Node at index #{index} is missing an ID"
                else
                  node_ids << id.to_s
                end
              end

              duplicate_ids = node_ids.tally.select { |_id, count| count > 1 }.keys
              duplicate_ids.each do |id|
                errors << "Duplicate node ID: #{id}"
              end

              known_ids = node_ids.to_set

              @edges.each_with_index do |edge, index|
                unless record_like?(edge)
                  errors << "Relationship at index #{index} must be a hash or model record"
                  next
                end

                source = read(edge, @source_key)
                target = read(edge, @target_key)

                if source.blank? || target.blank?
                  errors << "Relationship at index #{index} is missing an endpoint"
                  next
                end

                warnings << "Relationship at index #{index} has an unknown source" unless known_ids.include?(source.to_s)
                warnings << "Relationship at index #{index} has an unknown target" unless known_ids.include?(target.to_s)

                warnings << "Relationship at index #{index} is a self-loop" if source.to_s == target.to_s
              end

              {
                valid: errors.empty?,
                errors: errors,
                warnings: warnings,
                node_count: @nodes.size,
                edge_count: @edges.size,
                duplicate_node_ids: duplicate_ids
              }
            end

            private

            def invalid_result(message)
              {
                valid: false,
                errors: [message],
                warnings: [],
                node_count: nil,
                edge_count: nil,
                duplicate_node_ids: []
              }
            end

            def record_like?(record)
              record.respond_to?(:attributes) || record.is_a?(Hash)
            end

            def read(record, key)
              if record.respond_to?(:attributes)
                record.attributes[key] || record.attributes[key.to_sym]
              else
                record[key] || record[key.to_sym]
              end
            end
          end
        end
      end
    end
  end
end